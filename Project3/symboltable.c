#include "symboltable.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int lineno;

struct symboltable *createsymboltable(){
    struct symboltable *ret = (struct symboltable *)malloc(sizeof(struct symboltable));
    ret->root = NULL;
    return ret;
}
	
void add_identifier(struct symboltable *st, char *id, char *dtype,char *scope){
    if(lookup(st,id)){
        printf("Warning: Duplicate Definition of %s in this scope on Line %d\n",id,lineno);
        return;
    }
    if((st->root)==NULL){
        st->root = (struct node *)malloc(sizeof(struct node));
        (st->root)->id = strdup(id);
        (st->root)->dtype = strdup(dtype);
        (st->root)->line = lineno;
        (st->root)->scope = strdup(scope);
        (st->root)->next = NULL;
    }else{
        struct node* focus = st->root;
        while(focus->next) focus = focus->next;
        focus->next = (struct node *)malloc(sizeof(struct node));
        (focus->next)->id = strdup(id);
        (focus->next)->dtype = strdup(dtype);
        (focus->next)->line = lineno;
        (focus->next)->scope = strdup(scope);
        (focus->next)->next = NULL;
    }
}

int lookup(struct symboltable *st, char *key){
    struct node *focus = st->root;
    while(focus!=NULL){
        if(!strcmp(key,focus->id))
            return 1;
        focus=(focus->next);
    }
    return 0;
}

void merge_table(struct symboltable* dest, struct symboltable *src){
    struct node* focus = dest->root;
    if(focus==NULL)
        dest->root = src->root;
    else{
        while(focus->next) focus = focus->next;
        focus->next = src->root;
    }
}
