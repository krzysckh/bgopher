#include "bgopher.bi"

#include "curses.bi"
#include "crt/stdio.bi"

function basename(s as string) as string
  return right(s, len(s) - instrrev(s, "/"))
end function

sub ui_init
  dim as integer row, col
  initscr()
  cbreak()
  noecho()
  keypad(stdscr, true)

  if has_colors() then
    start_color()
    use_default_colors()
  end if

  curs_set(0)
end sub

sub ui_end
  endwin()
end sub

' doesn't handle <<anything>> well
function get_input(prompt as string) as string
  dim as string ret
  dim as integer x, y, maxx, maxy
  dim as ulong c

  getmaxyx(stdscr, maxy, maxx)
  y = maxy - 2

  attron(A_REVERSE)
  mvprintw(y, 0, "% *s", maxx, " ")
  ' sorry
  x = 0

  do while (chr(c) <> !"\n")
    if len(ret) = 0 then
      mvprintw(y, 0, "%s", prompt)
    else
      mvprintw(y, x, "% *s", x + 10, " ")
    end if

    c = getch()
    if c = KEY_BACKSPACE then
      if len(ret) > 0 then
        ret = left(ret, len(ret) - 1)
        x -= 1
        mvprintw(y, x, " ")
      end if
    else
      ret = ret & chr(c)
      mvprintw(y, x, "%c", c)
      x += 1
    end if
    'mvprintw(0, 0, "x = %d, len = %d, %s", x, len(ret), ret)

  loop
  ret = left(ret, len(ret) - 1)

  attroff(A_REVERSE)
  return ret
end function

function t_str (t as line_t) as string
  select case t
    case text_file : return " [txt] "
    case submenu   : return " [sub] "
    case nameserver: return " [srv] "
    case ecode     : return " [err] "
    case binhex    : return " [bih] "
    case dosf      : return " [dos] "
    case uuf       : return " [uue] "
    case fulltexts : return " [src] "
    case telnet    : return " [tel] "
    case binf      : return " [bin] "
    case mirror    : return " [mir] "
    case gif       : return " [gif] "
    case image     : return " [img] "
    case bitmap    : return " [img] "
    case movie     : return " [mov] "
    case audio     : return " [aud] "
    case document  : return " [doc] "
    case html      : return " [htm] "
    case info      : return "       "
    case pngimage  : return " [img] "
    case rtffile   : return " [rtf] "
    case wavfile   : return " [wav] "
    case pdffile   : return " [pdf] "
    case xmlfile   : return " [xml] "
    case unknown   : return " [???] "
  end select
end function

sub link_handler(o as obj ptr)
  select case o->t
    case submenu:
      ui_run(parse(g_get(o->hostname, o->selector, o->port)))

    case text_file:
      ui_run(t_pseudoparse(g_get(o->hostname, o->selector, o->port)))

    case binhex, dosf, uuf, binf, gif, image, bitmap, movie, audio, document, _
         html, pngimage, rtffile, wavfile, pdffile, xmlfile:
      dim as string dat = g_get(o->hostname, o->selector, o->port)
      dim as FILE ptr f = fopen(TEMP_FOLDER & "bgoph-downl-" & _
        basename(o->selector), "w")
      fwrite(strptr(dat), 1, len(dat), f)
      fclose(f)
      exec(ANY_HANDLER, TEMP_FOLDER & "bgoph-downl-" & basename(o->selector))


    case nameserver:
    case ecode     :
    case fulltexts :
    case telnet    :
    case mirror    :
    case info      :
    case unknown   :
  end select
end sub

sub ui_run(p as page ptr)
  dim as integer x = 0, y = 0, cur = 0, maxx, maxy, start = 0
  dim as obj ptr curs = @(p->l(0))
  dim as string c

  getmaxyx(stdscr, maxy, maxx)

  for i as integer = 0 to p->sz
    if len(p->l(i).display) = 0 then p->l(i).display = " "
  next

  clear_()
drawp:
  for i as integer = start to p->sz
    'if y > maxy then goto ref

    mvprintw(y, x, t_str(p->l(i).t))
    if @(p->l(i)) = curs then attron(A_UNDERLINE)
    mvprintw(y, x + 7, "%s", p->l(i).display)
    if @(p->l(i)) = curs then attroff(A_UNDERLINE)

      ' fill the line with nothing :^)
    mvprintw(y, x + 7 + len(p->l(i).display), "% *s", _
      maxx - x - 7 -len(p->l(i).display) , " ")
    y = y + 1
  next

ref:
  refresh()
  c = wchr(getch())

  select case c
    case "j":
      if curs <> @(p->l(p->sz)) then
        curs += 1
        cur  += 1
        if cur > maxy then
          start += maxy / 2
          cur -= maxy / 2
          clear_()
        end if
      end if
    case "k":
      if cur > 0 or (start > 0 and cur >= 0) then
        curs -= 1
        cur  -= 1
        if cur < 0 then
          'clear_()
          start -= 1
          cur += 1
        end if
      end if
    case "q":
      ui_end
      end 0
    case !"\n", "l":
      clear_()
      link_handler(curs)
    case "g":
      dim as uri_t ptr uri = parseuri(get_input("[enter url]"))
      if uri->hostname <> "-1" then _
        ui_run(parse(g_get(uri->hostname, uri->file, uri->port)))
    case "h":
      clear_()
      return
  end select

  y = 0
  goto drawp
end sub
