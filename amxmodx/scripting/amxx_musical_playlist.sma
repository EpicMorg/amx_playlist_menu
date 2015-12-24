#include <amxmodx>
#include <amxmisc>

#define PLUGIN "AMX Musical Playlist"
#define VERSION "1.1"
#define AUTHOR "AurZum (EpicMorg)"

#define MAX_SONGS	10 //set number of songs you want, default 10

new configsdir[200]
new configfile[200]
new song[MAX_SONGS][64]
new songdir[MAX_SONGS][64]
new bool:precached[MAX_SONGS]
new indexs[MAX_SONGS]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("amx_playlist_menu", "show_palylist_menu", ADMIN_LEVEL_E, "");
	register_concmd("amx_play","cmd_play",ADMIN_LEVEL_E," <Part Of Filename> ")
	register_concmd("amx_playlist","cmd_playlist",ADMIN_LEVEL_E," Displays a list of songs in the server playlist. ")
	register_concmd("amx_stopplay","cmd_stop",ADMIN_LEVEL_E," Stops currently playing sounds/music. ")
	register_clcmd("say /stop","cl_cmd_stop")
	
}

public show_palylist_menu(id, lvl, cid) {
	if(!cmd_access(id, lvl, cid, 0))
		return PLUGIN_HANDLED;

	new menu = menu_create("Playlist Menu", "mh_MyMenu");

	for(new i=0;i<MAX_SONGS;i++) {
		if(precached[i]) {	
			menu_additem(menu, song[i], "", 0);
		}
	}
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_setprop(menu, MPROP_PERPAGE, 7);
	menu_setprop(menu, MPROP_BACKNAME, "Prev");
	menu_setprop(menu, MPROP_NEXTNAME, "Next");
	menu_setprop(menu, MPROP_EXITNAME, "Exit");
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\w");

	menu_display(id, menu, 0);

	return PLUGIN_HANDLED;
}

public mh_MyMenu(id, menu, item) {
	if(item == MENU_EXIT) {
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);
	
	new commandline[128];
	format(commandline,sizeof(commandline),"amx_play %s",song[indexs[item]]);
	client_cmd(id,commandline);
	
	menu_destroy(menu);

	return PLUGIN_HANDLED;
}

public plugin_precache() {
	new songdir2[64];
	get_configsdir(configsdir,sizeof(configsdir));
	format(configfile,sizeof(configfile),"%s/music.ini",configsdir);
	new trash, index;
	for(new i=0;i<MAX_SONGS;i++) {
		precached[i]=false;
		read_file(configfile,i,song[i],63,trash);
		if(!equali(song[i][4],"")) {
			format(songdir[i],63,"music/epicmorg/%s",song[i]);
			format(songdir2,63,"sound/music/epicmorg/%s",song[i]);
			if(file_exists(songdir2)) {
				precached[i]=true
				precache_sound(songdir[i])
				indexs[index] = i;
				index++;
			}
		}
	}
}

public cmd_playlist(id,level,cid) {
	console_print(id,"Songs in server playlist:")
	for(new i=0;i<MAX_SONGS;i++) {
		if(precached[i]) {
			console_print(id,song[i])
		}
	}
	return PLUGIN_HANDLED
}

public cmd_stop(id,level,cid) {
	if (!cmd_access(id,level,cid,1)) {
		return PLUGIN_HANDLED
	}
	client_cmd(0,"mp3 stop;stopsound")
	client_print(0,print_chat,"Admin Turned The Music Off.")
	return PLUGIN_HANDLED
}

public cmd_play(id,level,cid) {
	if (!cmd_access(id,level,cid,2)) {
		return PLUGIN_HANDLED
	}
	client_print(id,print_chat,"cmd_play","");
	new arg1[32]
	read_argv(1,arg1,31)
	new songnum = MAX_SONGS
	for(new i=0;i<MAX_SONGS;i++) {
		if(precached[i] && containi(song[i],arg1)!=-1) {
			if(songnum!=MAX_SONGS) {
				console_print(id,"More than one file contains that phrase in it.")
				return PLUGIN_HANDLED
			}
			songnum = i
		}
	}
	if(songnum==MAX_SONGS) {
		console_print(id,"No file containing that phrase was found. Type amx_playlist to see songlist.")
		return PLUGIN_HANDLED
	}
	if(containi(song[songnum],".mp3")) {
		client_cmd(0,"mp3 play ^"sound/%s^"",songdir[songnum])
	}
	if(containi(song[songnum],".wav")) {
		client_cmd(0,"spk ^"%s^"",songdir[songnum])
	}
	client_print(0,print_chat,"Admin Has Played File ^"%s^" If you don't want to hear it, say /stop",song[songnum])
	return PLUGIN_HANDLED
}

public cl_cmd_stop(id) {
	client_cmd(id,"mp3 stop;stopsound")
	client_print(id,print_chat,"Music stopped")
	return PLUGIN_HANDLED
}