#include "bgopher.bi"

#include "curses.bi"

sub ui_init
  initscr()
  cbreak()
  noecho()
  keypad(stdscr, true)

  printw("halo")

  getch()
end sub

sub ui_end
  endwin()
end sub
