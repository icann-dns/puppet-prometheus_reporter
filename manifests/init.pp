# @summary Class to configure the prometheus reporter
# @param textfile_directory Location of the node_exporter collector.textfile.directory (Required)
# @param config_directory Directory to place the prometheus.yaml config file. The default value is the Puppet config directory of the
#         compiling puppet server.  If your agents have a different directory you will need to override this value.
# @param report_file_prefix Prefix for metrics files.
# @param report_file_mode File mode to set on report files.
# @param environments If specified, only creates metrics on reports from these environments
# @param reports If specified, only creates metrics from reports of this type (changes, events, resources, time)
# @param stale_time If specified, delete metric files for nodes that haven't sent reports in X days
# @param node_directory If specified, the directory we will look for a yaml file with ${fqdn}.yaml.  This yaml file will include 
#   additional metadata to inject as lables
# @param node_lables a list of node lables to pull out of the node_directory and inject into the metrics.  The yaml file should be a hash
#   of key/value pairs.  and string in the node_lables list will be pulled out of the hash and injected into the metrics as a label.
#   you can use dot notation to pull out nested values.  For example if the yaml file looks like this:
#   ---
#   node:
#     name: mynode
#     location: mylocation
#   and you specify node_lables => ['node.name', 'node.location'] then the metrics will have two additional labels: node_name="mynode" and node_location="myl
class prometheus_reporter (
  Stdlib::Absolutepath               $textfile_directory = '/var/lib/prometheus/node-exporter',
  Stdlib::Absolutepath               $config_directory   = $settings::config.dirname,
  String                             $report_file_prefix = 'puppet_report_',
  Stdlib::Filemode                   $report_file_mode   = '0644',
  Array[String[1]]                   $environments       = [],
  Array[Prometheus_reporter::Report] $reports            = [],
  Array[String[1]]                   $node_labels        = [],
  Optional[Integer]                  $stale_time         = undef,
  Optional[Stdlib::Absolutepath]     $node_directory     = undef,
) {
  $config = {
    'textfile_directory' => $textfile_directory,
    'report_file_prefix' => $report_file_prefix,
    'report_file_mode'   => Integer($report_file_mode, 8),
    'environments'       => $environments,
    'reports'            => $reports,
    'stale_time'         => $stale_time,
    'node_directory'     => $node_directory,
    'node_labels'        => $node_labels,
  }.filter |$k, $v| { !$v.empty }  # undef.empty is falsy
  file { "${config_directory}/prometheus.yaml":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => stdlib::to_yaml($config),
  }
}
