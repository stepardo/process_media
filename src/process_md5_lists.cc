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

typedef std::vector<Tupel *> md5_filelist;

static md5_filelist local_files;
static md5_filelist remote_files;

void
fill_list(const char *filename, md5_filelist &list)
{
  FILE *f = fopen(filename, "r");

  if(f == 0)
    {
      fprintf(stderr, "Could not open file %s\n", filename);
      exit(1);
    }

  char *line = NULL;
  size_t len;
  ssize_t read;
  char md5[1000], fname[1000];
  while ((read = getline(&line, &len, f)) > 0)
    {
      sscanf(line, "%s\t\t%s\n", md5, fname);
      list.push_back(new Tupel(md5, fname));
    }

  fclose(f);
}

void
print_existing_files(md5_filelist local_files, md5_filelist remote_files)
{
  for (const auto local : local_files)
    for (const auto remote : remote_files)
      if (!strcmp(local->md5(), remote->md5()))
        printf("File exists: local %s remote %s\n", local->filename(), remote->filename());
}

void
print_filename_clashes(md5_filelist local_files, md5_filelist remote_files)
{
  for (const auto local : local_files)
    for (const auto remote : remote_files)
      if (!strcmp(local->filename(), remote->filename()))
        printf("Clash: local %s remote %s\n", local->filename(), remote->filename());
}

int
main(int argc, char **argv)
{
  get_options(argc, argv);
  fill_list(opts._remote_file, remote_files);
  printf("Size = %d\n", remote_files.size());
  fill_list(opts._local_file, local_files);
  printf("Size = %d\n", local_files.size());
  if (opts.mode == Print_filename_clashes)
    print_filename_clashes(local_files, remote_files);
  else if (opts.mode == Print_existing_files)
    print_existing_files(local_files, remote_files);
  return 0;
}
