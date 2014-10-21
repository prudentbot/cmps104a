//main.cc

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

const string cpp_name = "/usr/bin/cpp";
string str_cpp_command;
string cpp_options;
FILE* str_in;
int cpp_opt;
const char* filename;

// Open a pipe from the C preprocessor.
// Exit failure if can't.
// Assignes opened pipe to FILE* yyin.

void str_cpp_popen (const char* filename) {
   str_cpp_command = cpp_name;
   str_cpp_command += " ";
   if (cpp_opt == 1) {
      str_cpp_command += "-D";
      str_cpp_command += cpp_options;
      str_cpp_command += " ";
   }
   str_cpp_command += filename;
   str_in = popen (str_cpp_command.c_str(), "r");
   if (str_in == NULL) {
      syserrprintf (str_cpp_command.c_str());
      exit (get_exitstatus());
   }
}

void str_cpp_pclose (void) {
   int pclose_rc = pclose (str_in);
   eprint_status (str_cpp_command.c_str(), pclose_rc);
   if (pclose_rc != 0) set_exitstatus (EXIT_FAILURE);
}

/*
bool want_echo () {
   return not (isatty (fileno (stdin)) and isatty (fileno (stdout)));
}
*/

void scan_opts (int argc, char** argv) {
   int option;
   opterr = 0;
   int yy_flex_debug = 0;
   int yydebug = 0;
   cpp_opt = 0;

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
   cout << "opening " << filename << " with options " << cpp_options << endl;
   str_cpp_popen (filename);
   DEBUGF ('m', "filename = %s, str_in = %p, fileno (str_in) = %d\n",
           filename, str_in, fileno (str_in));
   //scanner_newfilename (filename);
}

int main (int argc, char** argv) {
   //int parsecode = 0;

   set_execname (argv[0]);
   DEBUGSTMT ('m',
      for (int argi = 0; argi < argc; ++argi) {
         eprintf ("%s%c", argv[argi], argi < argc - 1 ? ' ' : '\n');
      }
   );

   scan_opts (argc, argv);

   //tokenize output (str_in)

   if (str_in != NULL) {
      int linenr = 1;
      char inputname[1024];
      strcpy(inputname, filename);
      for (;;) {
         char buffer[1024];
         char* fgets_rc = fgets(buffer, 1024, str_in);
         if (fgets_rc == NULL) break;
         int sscanf_rc = sscanf (buffer, "# %d \"%[^\"]\"",
                        &linenr, filename);
         if (sscanf_rc == 2) {
            printf ("DIRECTIVE: line %d file \"%s\"\n", linenr, filename);
            continue;
         }
         char* savepos = NULL;
         char* bufptr = buffer;
         for (int tokenct = 1;; ++tokenct) {
            char* token = strtok_r (bufptr, " \t\n", &savepos);
            bufptr = NULL;
            if (token == NULL) break;
            const string* str = intern_stringset (token);
            /*printf ("intern (\"%s\") returned %p->\"%s\"\n",
              token, str, str->c_str());
            */
            printf("token %d: [%s]\n",tokenct, token);
         }
      }
   }

   //dump stringset to file
   dump_stringset(stdout);

   return get_exitstatus();
}
