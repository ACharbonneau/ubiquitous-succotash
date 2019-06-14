#Written by Luiz Irber @luizirber

#! /usr/bin/env python

import argparse

if __name__ == "__main__":
   parser = argparse.ArgumentParser()
   parser.add_argument('snps')
   parser.add_argument('bedIntersect')
   args = parser.parse_args()

   with open(args.snps, 'r') as f:
       snps = set(l.strip() for l in f)

   with open(args.bedIntersect, 'r') as f:
       for line in f:
           if line.split('\t')[2] in snps:
               print(line, end='')
