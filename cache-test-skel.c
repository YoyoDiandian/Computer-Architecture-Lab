/*
YOUR NAME HERE
ECE 154A - Fall 2012
Lab 2 - Mystery Caches
Due: 12/3/12, 11:00 pm

Mystery Cache Geometries:
mystery0:
    block size = 
    cache size = 
    associativity = 
mystery1:
    block size = 
    cache size = 
    associativity = 
mystery2:
    block size = 
    cache size = 
    associativity = 
*/

#include <stdlib.h>
#include <stdio.h>

#include "mystery-cache.h"

/* 
   Returns the size (in B) of the cache
*/
int get_cache_size(int block_size) {
  /* YOUR CODE GOES HERE */
  int size = block_size; // 起始猜测大小为块大小
  flush_cache(); // 刷新缓存

  while (1) {
    for (int i = 0; i < size; i += block_size) {
      access_cache(i); // 访问地址
    }
    // 检查缓存命中
    if (!access_cache(0)) { // 如果缓存未命中，则超出缓存大小
      break;
    }
    size *= 2; // 缓存大小通常是 2 的幂，翻倍测试
    flush_cache();
  }

  return size;
}

/*
   Returns the associativity of the cache
*/
int get_cache_assoc(int size) {
  /* YOUR CODE GOES HERE */
  int assoc = 1; // 假设相联度至少为1
  flush_cache();

  while (1) {
    for (int i = 0; i < assoc * size; i += size) {
      access_cache(i); // 访问每组的不同块
    }
    // 检查缓存命中
    if (!access_cache(0)) { // 如果缓存未命中，则相联度超出
      break;
    }
    assoc++; // 增加猜测的相联度
    flush_cache();
  }

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
    access_cache(0); // 访问基地址
    if (!access_cache(block_size)) { // 增加步幅后检查命中
      break;
    }
    block_size *= 2; // 块大小通常是 2 的幂
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
