# s3_explore S3Mock bucket-name
# Rails console alternative:
#   s3 = Aws::S3::Client.new
#   resp = s3.list_objects_v2(bucket: 'bucket-name')
function s3_explore() {
  local profile=${1?} bucket=${2?} ls_key_col=5

  echo_eval aws s3 ls --profile "$profile" "$bucket" --human-readable --recursive --summarize \
    | fzf --accept-nth=$ls_key_col --ansi --preview-window 'down' --preview \
      "aws s3api head-object --profile $profile --bucket $bucket --key {$ls_key_col} | jq -C"
}
