//main.cc
//jshedel@ucsc.edu

#include <string>
#include <vector>
#include <iostream>
using namespace std;

#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "stringset.h"
#include "auxlib.h"
#include "lyutils.h"
#include "astree.h"
#include "yyparse.h"

const string cpp_name = "/usr/bin/cpp";
string yyin_cpp_command;
string cpp_options;
int cpp_opt;
const char* filename;

extern astree* yyparse_astree;

// Open a pipe from the C preprocessor.
// Exit failure if can't.
// Assignes opened pipe to FILE* yyin.

void yyin_cpp_popen (const char* filename) {
   yyin_cpp_command = cpp_name;
   yyin_cpp_command += " ";
   if (cpp_opt == 1) {
      yyin_cpp_command += "-D";
      yyin_cpp_command += cpp_options;
      yyin_cpp_command += " ";
   }
   yyin_cpp_command += filename;
   yyin = popen (yyin_cpp_command.c_str(), "r");
   if (yyin == NULL) {
      syserrprintf (yyin_cpp_command.c_str());
      exit (get_exitstatus());
   }
}

void yyin_cpp_pclose (void) {
   int pclose_rc = pclose (yyin);
   eprint_status (yyin_cpp_command.c_str(), pclose_rc);
   if (pclose_rc != 0) set_exitstatus (EXIT_FAILURE);
}

// Chomp the last character from a buffer if it is delim.
void chomp (char* string, char delim) {
   size_t len = strlen (string);
   if (len == 0) return;
   char* nlpos = string + len - 1;
   if (*nlpos == delim) *nlpos = '\0';
}


void scan_opts (int argc, char** argv) {
   int option;
   opterr = 0;
   cpp_opt = 0;
   yy_flex_debug = 0;
   yydebug = 0;

   for(;;) {
      option = getopt (argc, argv, "@:elyD:");
      if (option == EOF) break;
      switch (option) {
         case '@': set_debugflags (optarg);   break;
         case 'l': yy_flex_debug = 1;         break;
         case 'y': yydebug = 1;               break;
         case 'D': cpp_opt = 1; cpp_options = optarg;	  break;
         default:  errprintf ("%:bad option (%c)\n", optopt); break;
      }
   }
   if (optind > argc) {
      errprintf ("Usage: %s [-ly] [filename]\n", get_execname());
      exit (get_exitstatus());
   }
   filename = optind == argc ? "-" : argv[optind];
   //cout << "opening " << filename << " with options " << cpp_options << endl;
   yyin_cpp_popen (filename);
   DEBUGF ('m', "filename = %s, yyin = %p, fileno (yyin) = %d\n",
           filename, yyin, fileno (yyin));
   //scanner_newfilename (filename);

}

int main (int argc, char** argv) {
   set_execname (argv[0]);
   DEBUGSTMT ('m',
      for (int argi = 0; argi < argc; ++argi) {
         eprintf ("%s%c", argv[argi], argi < argc - 1 ? ' ' : '\n');
      }
   );

   scan_opts (argc, argv);

   //remove directory information, append .str
   char* outfilename = basename( (char*) filename);
   string p = strtok(outfilename, ".");
   string s = strtok(outfilename, ".");
   p += ".str";
   s += ".tok";


   scanner_outputfile(s.c_str());

   printf("%s\n", "here");
   yyparse();

   //open the output file
   FILE* outfile = fopen(p.c_str(), "w");
   //dump stringset to file
   dump_stringset(outfile);
   
   dump_astree(stdout, yyparse_astree);

   return get_exitstatus();
}
