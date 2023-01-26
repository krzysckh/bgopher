#include "bgopher.bi"
#include "regex.bi"

' this is a really sad function
function parseuri(byval s as string) as uri_t ptr
  dim as uri_t ptr ret = new uri_t
  dim as regex_t re
  dim as regmatch_t pm
  dim as zstring ptr buf = strptr(s)
  dim as integer res, portgiven = 0, portlen

  ret->port = "70"

  if (left(*buf, 9) = "gopher://") then buf = buf + 9

  regcomp(@re, "(^.*:\d+.*$)", REG_EXTENDED)
  res = regexec(@re, buf, 1, @pm, 0)
  regfree(@re)
  if res = 0 then
    portgiven = 1
    regcomp(@re, ":\d+", REG_EXTENDED)
    res = regexec(@re, buf, 1, @pm, 0)
    ret->port = left(*(buf + pm.rm_so + 1), pm.rm_eo - pm.rm_so - 1)
    portlen = pm.rm_eo - pm.rm_so - 1
    regfree(@re)
  end if

  if portgiven then
    regcomp(@re, "^.*:", REG_EXTENDED)
  else
    regcomp(@re, "^.*?(/|$)", REG_EXTENDED)
  end if

  res = regexec(@re, buf, 1, @pm, 0)
  if res <> 0 then
    print ret->port
    ret->port = "-1"
    regfree(@re)
    return ret
  end if

  ret->hostname = left(*buf, pm.rm_eo)
  if right(ret->hostname, 1) = "/" then ret->hostname = _
    left(ret->hostname, len(ret->hostname) - 1)
  buf = buf + pm.rm_eo

  if portgiven then
    buf = buf + portlen
  end if
  regfree(@re)

  if len(*buf) = 0 then
    ret->file = "/"
  else
    ret->file = *(buf - 1)
  end if

  return ret
end function
