safe do

  local :path => "/etc/backups/:kind/:id"

  s3 do
    key "AKIAIR46365NFZLQ5QUA"
    secret "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"
    bucket "lilly_lightweight_bucket1"
    path ":kind/:id"
  end

  keep do
    local 100
    s3 100
  end

  mysqldump do
    options "-ceKq --single-transaction --create-options"
    user "root"
    # password "ysaura5"
    socket "/tmp/mysql.sock"
    database 'server_development'
  end

  # tar do
  #   archive "rock_on/" do
  #     files "../"
  #   end
  # end

end