#!/usr/bin/ruby -w

require 'socket'

Socket.tcp_server_loop(9100){ |sock,clinet_addrinfo|
    Thread.new{
        begin
            print sock.read
            sock.puts "Echo from server!"
            IO.copy_stream(sock,sock)
        ensure
            sock.close
        end
    }
}
