//Here lies a poor attempt at using someone elses C code to read input from STDIN
//without having to wait for new lines.
//Apparently its old and lua's api has changed.
//also, maybe ncurses? Not sure, either way its completely broken for me
//I now use the input.lua file to archive this task.
//Alos note, the instrcution on how to build it that is included in this file may be wrong.
//So....yea....did I mention this code didn't work for me?.....

/* Build me with:
   gcc -shared -o kb.so -undefined dynamic_lookup kb.c -lncurses
*/

/* Copyright (C) 2012 Ross Andrews
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/lgpl.txt>. */

#include <ncurses.h>

#include <lua5.3/lua.h>     //had to enter the lua5.3 thing in front. Else it couldn't find lua.....As you can see, I can't C
#include <lua5.3/lualib.h>  //had to enter the lua5.3 thing in front. Else it couldn't find lua.....As you can see, I can't C
#include <lua5.3/lauxlib.h> //had to enter the lua5.3 thing in front. Else it couldn't find lua.....As you can see, I can't C

int getch_wrapper(lua_State *L);

int luaopen_kb(lua_State *L){
	/*
    luaL_Reg fns[] = {
        {"getch", getch_wrapper},
        {NULL, NULL}
    };
	*/
    //luaL_openlib(L, "kb", fns, 0);
	lua_newtable(L);
	luaL_setfuncs(L,getch_wrapper,0);
    initscr(); /* Start curses */
    //raw(); /* Turn off line buffering */
    //set_escdelay(25); /* Shorten delay after ESC key to something reasonable */
    //keypad(stdscr, TRUE); /* Grab ALL kbd input */
    //refresh(); /* Store screen state so endwin works */
    endwin(); /* Leave curses mode */

    return 0;
}

int getch_wrapper(lua_State *L){
    reset_prog_mode(); /* Get back into curses */
    lua_pushnumber(L, getch()); /* Grab a char and push it */
    endwin(); /* Get out of curses again */
    return 1;
}
