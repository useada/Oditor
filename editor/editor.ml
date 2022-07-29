(*
    file: editor.ml
    Global editor definition and setup
*)

(*** Types and global variables ***)

(* Oditor version *)
let version = "0.0.1"

(* Editor Row definition *)
type erow = {
    mutable size : int;
    mutable chars : string
};;

(* Editor mode *)
type emode =
    | NORMAL
    | COMMAND
    | INSERT;;

let string_of_mode mode = match mode with
    | NORMAL -> "NORMAL"
    | COMMAND -> "COMMAND"
    | INSERT -> "INSERT";;

(* Terminal definition *)
type termio = {
    mutable rows : int;         (* Number of rows in terminal *) 
    mutable rowoff : int;       (* Current row offset *)
    mutable cols : int;         (* Number of columns in terminal *)
    mutable colsoff : int;      (* Current column offset *)
    mutable x : int;            (* Cursor x position *)
    mutable y : int;            (* Cursor y position *)
    mutable text : erow list;   (* Text buffer *)
    mutable numlines : int;     (* Number of lines in text buffer *)
    mutable mode : emode;       (* Current Editor mode*)
    mutable command : string;   (* Command buffer *)
    io : Unix.terminal_io       (* Editor terminal io *)
};;

(* Convert int option to int *)
let int_of_intop = function None -> 0 | Some n -> n;;

(* Global Editor *)
let term = 
    let (r, c) = (Terminal_size.get_rows (), Terminal_size.get_columns ()) in
    {
        rows = int_of_intop r;
        rowoff = 0;
        cols = int_of_intop c;
        colsoff = 0;
        x = 0;
        y = 0;
        text = [];
        numlines = 0;
        mode = NORMAL;
        command = "";
        io = Unix.tcgetattr Unix.stdin
    };;

(*** Terminal setup ***)

(* Load current term size *)
let load_term_size () = 
    let (r, c) = (Terminal_size.get_rows (), Terminal_size.get_columns ()) in
    term.rows <- (int_of_intop r); term.cols <- (int_of_intop c);;

(* Initial terminal char size *)
let isize = term.io.c_csize;;
(* Initial terminal read minimal input *)
let imin = term.io.c_vmin;;
(* Initial terminal read timeout *)
let itime = term.io.c_vtime

(* Open terminal raw mode
    Terminal with disabled echo and read byte by byte *)
let enter_raw () =
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
        { term.io with Unix.c_icanon = false; Unix.c_echo = false;
            Unix.c_isig = false; Unix.c_ixon = false; 
            Unix.c_icrnl = false; Unix.c_opost = false;
            Unix.c_brkint = false; Unix.c_inpck = false;
            Unix.c_istrip = false; Unix.c_csize = 8;
            Unix.c_vmin = 0; Unix.c_vtime = 1};;

(* Exit terminal raw mode *)
let exit_raw () =
    Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
        { term.io with Unix.c_icanon = true; Unix.c_echo = true;
            Unix.c_isig = true; Unix.c_ixon = true; 
            Unix.c_icrnl = true; Unix.c_opost = true;
            Unix.c_brkint = true; Unix.c_inpck = true;
            Unix.c_istrip = true; Unix.c_csize = isize;
            Unix.c_vmin = imin; Unix.c_vtime = itime};;
