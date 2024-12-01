/*
YOUR NAME HERE
ECE 154A - Fall 2012
Lab 2 - Mystery Caches
Due: 12/3/12, 11:00 pm

Mystery Cache Geometries:
mystery0:
    block size = 64 bytes
    cache size = 4194304 bytes
    associativity = 16
mystery1:
    block size = 4 bytes
    cache size = 4096 bytes
    associativity = 1
mystery2:
    block size = 32 bytes
    cache size = 4096 bytes
    associativity = 128
*/

#include <stdlib.h>
#include <stdio.h>

#include "mystery-cache.h"

/* 
   Returns the size (in B) of the cache
*/
int get_cache_size(int block_size) {
  /* YOUR CODE GOES HERE */
  int size = block_size;
  flush_cache();

  while (1) {
    for (int i = 0; i < size; i += block_size) {
      access_cache(i);
    }
    if (!access_cache(0)) {
      break;
    }
    size *= 2;
    flush_cache();
  }
  size /= 2;

  return size;
}

/*
   Returns the associativity of the cache
*/
int get_cache_assoc(int size) {
  /* YOUR CODE GOES HERE */
  int assoc = 1;
  flush_cache();

  while (1) {
    for (int i = 0; i < assoc * size; i += size) {
      access_cache(i);
    }
    if (!access_cache(0)) {
      break;
    }
    assoc++;
    flush_cache();
  }

  assoc--;
  return assoc;
}

/*
   Returns the size (in B) of each block in the cache.
*/
int get_block_size() {
  /* YOUR CODE GOES HERE */
  int block_size = 1;
  flush_cache();
  while (1) {
    access_cache(0);
    if (!access_cache(block_size)) {
      break;
    }
    block_size *= 2;
    flush_cache();
  }
  return block_size;
}

int main(void) {
  int size;
  int assoc;
  int block_size;
  
  /* The cache needs to be initialized, but the parameters will be
     ignored by the mystery caches, as they are hard coded.
     You can test your geometry paramter discovery routines by 
     calling cache_init() w/ your own size and block size values. */
  cache_init(0,0);
  
  block_size = get_block_size();
  size = get_cache_size(block_size);
  assoc = get_cache_assoc(size);


  printf("Cache size: %d bytes\n",size);
  printf("Cache associativity: %d\n",assoc);
  printf("Cache block size: %d bytes\n",block_size);
  
  return EXIT_SUCCESS;
}
