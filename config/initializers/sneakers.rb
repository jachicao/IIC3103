Sneakers.configure(
    :amqp => ENV['AMQP_URL'],
    :daemonize => ENV['DOCKER_RUNNING'] != nil,
    :log  => 'log/sneakers.log',
    :pid_path => 'log/sneakers.pid',
)