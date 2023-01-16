#include "crt/sys/socket.bi"
#include "crt/string.bi"
#include "crt/netdb.bi"

function g_get(addr as string, file as string) as string
  dim hints as addrinfo
  dim res as addrinfo ptr
  dim as integer sockfd, bytec, f_bytec
  dim as string header = file & !"\n"
  dim buf as string * 1024
  dim full as string

  f_bytec = 0

  memset @hints, 0, sizeof(hints)
  hints.ai_family = AF_UNSPEC
  hints.ai_socktype = SOCK_STREAM

  getaddrinfo(addr, "70", @hints, @res)
  sockfd = socket_(PF_INET, SOCK_STREAM, IPPROTO_TCP)
  ' no clue why socket() doesn't work
  ' it's an alias, but i have no idea what does that mean
  ' so i looked at the header file, and it just defines socket_
  ' soooo
  connect(sockfd, res->ai_addr, res->ai_addrlen)
  send(sockfd, header, len(header), 0)

  do
    bytec = recv(sockfd, buf, 1023, 0)
    f_bytec += bytec
    buf[bytec] = 0
    full = full & buf
  loop while (bytec)

  buf[bytec] = 0

  close(sockfd)

  return left(full, f_bytec)
end function

