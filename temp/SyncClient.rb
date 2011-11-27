#!/usr/bin/ruby -w

require 'socket'

Socket.tcp("localhost",9100) { |sock|
    sock.print "hello!"
    sock.close_write
    print sock.read
}
