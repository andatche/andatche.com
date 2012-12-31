module ExtendBlogging
  GenerateError = Class.new(StandardError)

  def posts
    sorted_articles.reject{ |i| i[:is_hidden] }
  end

  # Infer the post's created_at time from the filename for the specified post
  def extract_post_created_at post
    post.identifier[%r{/(\d+-\d+-\d+)[\w-]+/?$}, 1]
  end

  # Override Blogging#articles to select items in /post, rather than of kind article.
  # Also makes sure the kind defaults to "article" and created_at defaults to being extracted
  # from the filename, rather than having to specify both in the metadata.
  def articles
    posts = @items.select {|item| item.identifier =~ %r{^/post} }
    # Setup some things that the Blogging module expect
    posts.each do |item|
      item[:kind] ||= "article"
      item[:created_at] ||= extract_post_created_at(item)
    end
    posts
  end

  # Get the last x posts, where x defaults to 25.
  def recent_posts count=25
    posts[0...count].dup
  end

  # Returns an array of monthly archive objects in descending date objects. Only includes a month/year if it has posts
  # therein. Use #to_s for the pretty name (eg. "November 2011") and #to_path for the URL path (eg. "/blog/2011/")
  def monthly_archives
    ma = Struct.new(:year, :month) do
      def to_s
        "#{Date::MONTHNAMES[month]} #{year}"
      end

      def to_path
        "/blog/#{year}/#{"%.2d" % month}/"
      end
    end
    monthly_posts.inject({}) do |hash, (year, months)|
      hash[year] = months.keys
      hash
    end.map { |year, months| months.map { |month| ma.new(year, month) } }.flatten.sort_by {|e| [e.year, e.month] }.reverse
  end

  def monthly_posts
    # Turn the array of posts into nested hashes of year and months, containing the posts therein that year/month
    @monthly_posts ||= posts.inject({}) do |hash, post|
      year, month = attribute_to_time(post[:created_at]).strftime("%Y %m").split.map(&:to_i)
      hash[year] ||= {}
      hash[year][month] ||= []
      hash[year][month] << post
      hash
    end
  end

  # The main method to kick everything off.
  # Generates the archive, monthly archives and author archives
  # Expects the items in /posts to be named `yyyy-mm-dd-title` - like jekyll
  def generate_blog!
    raise GenerateError, "no blog posts found in ./content/posts/" unless posts && posts.count > 0

    generate_monthly_archives
    generate_yearly_archives
    generate_tag_archives
  end

  # Generates /blog/:year/:month(/page/:i)/ pages, listing posts in each month on as many pages as needed
  def generate_monthly_archives
    # Build nested hash of arrays of available [year][month]
    years = monthly_posts.keys.sort.inject({}) { |hash, year| hash[year] = monthly_posts[year].keys.sort; hash }
    i = 0
    years.each_pair do |year, months|
      j = 0
      months.each do |month|

        @items << Nanoc3::Item.new(
          %{<%= render "blog_archive", @item.attributes %>},
          {
            :title => "from #{Date::MONTHNAMES[month]} #{year}",
            :feed_url => "/blog/#{year}/#{"%.2d" % month}/feed/",
            :posts => monthly_posts[year][month],
            :next_url => (months[j+1] != nil ? "/blog/#{year}/#{"%.2d" % months[j+1]}" : (years.keys[i+1] != nil ? "/blog/#{years.keys[i+1]}/#{"%.2d" % years[years.keys[i+1]][0]}" : nil)),
            :prev_url => (j != 0 ? "/blog/#{year}/#{"%.2d" % months[j-1]}" : (i != 0 ? "/blog/#{years.keys[i-1]}/#{"%.2d" % years[years.keys[i-1]][-1]}" : nil)),
            :year => months
          },
          "/blog/#{year}/#{"%.2d" % month}/"
        )

        # Generate atom feed
        @items << Nanoc3::Item.new(
          %{<%= atom_feed :title => "andatche.com - archived posts from #{Date::MONTHNAMES[month]} #{year}", :articles => @item[:posts], :limit => 25 %>},
          {
            :posts => monthly_posts[year][month]
          },
          "/blog/#{year}/#{"%.2d" % month}/feed/"
        )
        j += 1
      end
      i += 1
    end
  end

  # Generates /blog/:year/:yyyy)/ pages, listing posts in each year
  def generate_yearly_archives
    # Build nested hash of arrays of available [year][month]
    years = monthly_posts.keys.sort
    i = 0
    years.each do |year|
      @items << Nanoc3::Item.new(
        %{<%= render "blog_archive", @item.attributes %>},
        {
          :title => "from #{year}",
          :feed_url => "/blog/#{year}/feed/",
          :posts => monthly_posts[year].values.flatten,
          :next_url => ("/blog/#{"%s/" % years[i+1]}" unless years[i+1] == nil),
          :prev_url => ("/blog/#{"%s/" % years[i-1]}" unless i == 0)
        },
        "/blog/#{year}/"
      )

      # Generate atom feed
      @items << Nanoc3::Item.new(
        %{<%= atom_feed :title => "andatche.com - archived posts from #{year}", :articles => @item[:posts], :limit => 25 %>},
        {
          :posts => monthly_posts[year].values.flatten
        },
        "/blog/#{year}/feed/"
      )
      i += 1
    end
  end

  def all_post_tags
    posts.map {|i| i[:tags] }.flatten.compact.uniq
  end

  def generate_tag_archives
    # Generate tag archive page
    all_post_tags.each do |tag|
      @items << Nanoc3::Item.new(
        %{<%= render "blog_archive", @item.attributes %>},
        {
          :title => "tagged \"#{tag}\"",
          :feed_url => "/blog/tag/#{slugify(tag)}/feed/",
          :posts => posts_with_tag(tag),
        },
        "/blog/tag/#{slugify(tag)}"
      )

      # Generate atom feed
      @items << Nanoc3::Item.new(
        %{<%= atom_feed :title => "andatche.com - posts tagged '#{tag}'", :articles => @item[:posts], :limit => 25 %>},
        {
          :posts => posts_with_tag(tag)
        },
        "/blog/tag/#{slugify(tag)}/feed/"
      )
    end
  end

  def posts_with_tag tag
    posts.select {|post| post[:tags] && post[:tags].include?(tag) }
  end

  def tags_for_post post, params={}
    params ||= {}
    params[:separator]  ||= ", "
    params[:base_url]   ||= "/blog/tag/"
    params[:none_text]  ||= "(none)"

    if post[:tags] && !post[:tags].empty?
      post[:tags].map {|tag| link_for_post_tag(tag, params[:base_url]) }.join(params[:separator])
    else
      params[:none_text]
    end
  end

  def link_for_post_tag name, base_uri
    %{<a href="#{h base_uri}#{h slugify(name)}/" rel="tag">#{h name}</a>}
  end

  def slugify str
    str.downcase.gsub(/\s+/, "-").gsub(/-{2,}/, "-")
  end
end