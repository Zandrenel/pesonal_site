:- use_module(library(http/http_error)).
:- use_module(library(http/http_files)).
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/html_write)).
:- use_module(library(http/html_head)).
:- use_module(library(http/http_path)).
:- use_module(library(settings)).


:- multifile user:file_search_path/2.
:- multifile http:location/3.

:- dynamic user:file_search_path/2.
:- dynamic   http:location/3.


% FILE SEARCH PATHS

:- prolog_load_context(directory, Dir),
   (   user:file_search_path(swi_site, Dir)
   ->  true
   ;   asserta(user:file_search_path(swi_site, Dir))
   ).

user:file_search_path(gallery_images, swi_site(gallery_images)).


http:location(static, '/s', []).
http:location(files, '/f', []).
http:location(gallery_images, static('gallery'), []).
http:location(images, static('imgs'), []).




serve_files(Request) :-
    http_reply_from_files('files', [], Request).
serve_files(Request) :-
    http_reply_from_files('/f', [], Request).
serve_files(Request) :-
	  http_404([], Request).

get_static(Request) :-
    http_reply_from_files('static', [], Request).
get_static(Request) :-
    http_reply_from_files('/s', [], Request).
get_static(Request) :-
	  http_404([], Request).



:- setting(http:served_file_extensions,
	   list(atom),
	   [ html, gif, png, jpeg, jpg, css, js, tgz, exe, c, zip ],
	   'List of extensions that are served as plain files').

% Resource Files
:- html_resource(static('styles.css'), []).

:- html_resource(swi_site,
		 [ virtual(true)]).

  % URL handlers
:- http_handler(root(.), home_page, []).
:- http_handler(root(gallery), gallery, []).
:- http_handler(root(test), page_test, []).
:- http_handler(files(.), serve_files, [prefix]).
:- http_handler(static(.), get_static, [prefix]).
:- http_handler(root(about), about_me, [prefix]).



home_page(_Request) :-
    reply_html_page(
	[title('Hello_World!')],
	[
	    \html_requires(static('styles.css')),
	    \nav_bar,
	    h1('Hello!!'),
	    div(id(main),
		[
		    p('Welcome to my website! this is the start of a future feature which professional looking hub!'),
		    div([style='justify-content: center;'],
			[p('This is a picture of Tiddles Supposedly')]
		       ) 
		])
	]).


gallery(_Request) :-
    directory_files('./static/gallery',F01),
    delete(F01,'.',F02),
    delete(F02,'..',F0),
    format_imgs(F0,F),
    reply_html_page(
	[title('Gallery')],
	[\html_requires(static('styles.css')),
	 \nav_bar,
	 h1([style='text-align:center;'],['===--Tiddles--===']),
	 div(id(display),F)]
    ).


page_test(_Request) :-
    reply_html_page([title(test)],
		    [
			\html_requires(static('styles.css')),
			\nav_bar,
			h1('Test 123')
			div(id(doc_body),[
			    %div(id(leftcolumn),_),
			    div(id(main),
				    p('This page as it stands is currently empty but honestly thats ok for now. For now this page may be used when testing features, or whatnot. Maybe for just adding randome blurbs of text, I may even figure out how to host various personal projects that are running and queriable from this page on this page. But as it stands this page is a simple test. A test of time for how long I keep it here and a test as in itself for how can I break it next and make it better.')
				   
				   )  
			    %div(id(rightcolumn),_)
			   ])
		    ]).

about_me(_Request) :-
    reply_html_page([title(test)],
		    [
			\html_requires(static('styles.css')),
			\nav_bar,
			p('Hello! Welcome to my about me section, I hope there is something interesting and useful for people to learn! May ye enjoy!'),
			h3('Languages'),
			ul([
			    li('Prolog'),
			    li('Java'),
			    li('Python'),
			    li('C++'),
			    li('Lisp'),
			    li('Bash')
			])
		    ]).


% Helper methods for the gallery

format_imgs([],[]).
format_imgs([H1|T1],[H2|T2]):-
    http_absolute_location(gallery_images(H1), P, []),
    H2 = div(img([class(gallery_image),src(P),alt=H1])),
    format_imgs(T1,T2).

% --------- To list function ---------

% ---------Navigation Bar---------

nav_bar -->
    {
	findall(Name, nav(Name, _), ButtonNames),
	maplist(as_top_nav, ButtonNames, TopButtons)
    },
    html([div(
	      id(top_nav_bar),
	      ul(id="navigationbar",TopButtons)
	  )]).


as_top_nav(Name, li(class(navitem),a([href=HREF, class=topnav], Name))) :-
	nav(Name, HREF).


nav(home, '/').
nav(gallery, '/gallery').
nav(test, '/test').
nav(files, '/f').
nav(about, '/about').


server(Port) :-
    http_server(http_dispatch, [port(Port)]).



:- initialization(server(3030)).


