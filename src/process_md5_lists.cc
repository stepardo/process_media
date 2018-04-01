#include <cstdio>
#include <cassert>
#include <vector>
#include <getopt.h>
#include <cstdlib>
#include <cstring>

enum {
  Print_existing_files = 1,
  Print_filename_clashes,
};

struct options
{
  ~options()
  {
    free(_local_file);
    free(_remote_file);
  }
  void local_file(const char *s)
  { _local_file = strdup(s); }
  void remote_file(const char *s)
  { _remote_file = strdup(s); }
  char *_local_file;
  char *_remote_file;
  unsigned mode;
};

static options opts;

void
print_usage_and_die(char **argv)
{
  fprintf(stderr, "Usage: %s -l local_file -r remote_file MODE\n", argv[0]);
  fprintf(stderr,
          "MODE:\n"
          "           -c    Print filename clashes\n"
          "           -p    Print files that exist remotely\n");
  exit(1);
}

void
get_options(int argc, char **argv)
{
  int opt;
  opts.mode = 0;
  while ((opt = getopt(argc, argv, "l:r:pc")) != -1)
    {
      switch (opt)
        {
        case 'l':
          {
            printf("Local file: %s\n", optarg);
            opts.local_file(optarg);
          }
          break;
        case 'r':
          {
            printf("Remote file: %s\n", optarg);
            opts.remote_file(optarg);
          }
          break;
        case 'p':
          opts.mode = Print_existing_files;
          break;
        case 'c':
          opts.mode = Print_filename_clashes;
          break;
        default:
          print_usage_and_die(argv);
        }
    }
  if (!opts.mode || !opts._local_file || !opts._remote_file)
    print_usage_and_die(argv);
}

class Tupel
{
public:
  Tupel(const char *md5sum, const char *filename)
  {
    _md5sum = strdup(md5sum);
    _filename = strdup(filename);
  }
  ~Tupel()
  {
    free(_md5sum);
    free(_filename);
  }
  char *md5()
  { return _md5sum; }
  char *filename()
  { return _filename; }

private:
  char *_md5sum;
  char *_filename;
};

typedef std::vector<Tupel> md5_filelist;

static md5_filelist local_files;
static md5_filelist remote_files;

int
main(int argc, char **argv)
{
  get_options(argc, argv);
  return 0;
}
