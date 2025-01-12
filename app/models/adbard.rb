class Adbard < Ad

  field :adbard_host_id, :type => String
  field :adbard_site_key, :type => String

  validates_presence_of     :adbard_host_id
  validates_presence_of     :adbard_site_key

  def ad
    return "<!--Ad Bard advertisement snippet, begin -->
    <script type='text/javascript'>
    var ab_h = '#{adbard_host_id}';
    var ab_s = '#{adbard_site_key}';
    </script>
    <script type='text/javascript' src='http://cdn1.adbard.net/js/ab1.js'></script>
    <!--Ad Bard, end -->
    "
  end
end