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
	
void add_identifier(struct symboltable *st, char *id, char *dtype){
    if((st->root)==NULL){
        st->root = (struct node *)malloc(sizeof(struct node));
        (st->root)->id = strdup(id);
        (st->root)->dtype = strdup(dtype);
        (st->root)->line = lineno;
        (st->root)->scope = strdup("");
        (st->root)->next = NULL;
    }else{
        struct node* focus = st->root;
        while(focus->next) focus = focus->next;
        focus->next = (struct node *)malloc(sizeof(struct node));
        (focus->next)->id = strdup(id);
        (focus->next)->dtype = strdup(dtype);
        (focus->next)->line = lineno;
        (focus->next)->scope = strdup("");
        (focus->next)->next = NULL;
    }
}

struct node* lookup(struct symboltable *st, char *key, struct node* starthere){
    if(key==NULL)
        key = strdup("");
    struct node *focus = starthere;
    while(focus!=NULL){
        if(!strcmp(key,focus->id))
            return focus;
        focus=(focus->next);
    }
    return NULL;
}

void apply_scope(struct symboltable *st, char *scope){
    struct node *focus = st->root;
    while(focus){
        char *newscope = (char *)malloc(strlen(scope)+1+strlen(focus->scope));
        strcpy(newscope,scope);
        if(strlen(focus->scope)){
            strcat(newscope,".");
            strcat(newscope,focus->scope);
        }
        free(focus->scope);
        focus->scope = newscope;
        focus = focus->next;
    }
}

void merge_table(struct symboltable* dest, struct symboltable *src, int check_conflict){
    struct node* focus = dest->root;
    if(focus==NULL)
        dest->root = src->root;
    else{
        while(focus->next) focus = focus->next;
        struct node *ins = src->root;
        while(ins){
            if(check_conflict){
                struct node* lu = lookup(dest,ins->id,dest->root);
                if(lu&&!strcmp(ins->scope,lu->scope)){
                    printf("Semantic Warning: Redefinition of identifier %s on Line %d\n",ins->id,ins->line);
                }else{
                    focus->next = (struct node *)malloc(sizeof(struct node));
                    (focus->next)->id = strdup(ins->id);
                    (focus->next)->dtype = strdup(ins->dtype);
                    (focus->next)->line = ins->line;
                    (focus->next)->scope = strdup(ins->scope);
                    (focus->next)->next = NULL;
                    focus = focus->next;
                }
            }else{
                focus->next = (struct node *)malloc(sizeof(struct node));
                (focus->next)->id = strdup(ins->id);
                (focus->next)->dtype = strdup(ins->dtype);
                (focus->next)->line = ins->line;
                (focus->next)->scope = strdup(ins->scope);
                (focus->next)->next = NULL;
                focus = focus->next;
            }
            ins = ins->next;
        }
        focus->next = NULL;
    }
}

void assign_datatype(struct symboltable *st, char *dtype){
    struct node* focus = st->root;
    while(focus){
        char *newdtype = (char *)malloc(strlen(focus->dtype)+strlen(dtype));
        strcpy(newdtype,dtype);
        focus->dtype[strlen(focus->dtype)-1] = '\0';
        strcat(newdtype,focus->dtype);
        free(focus->dtype);
        focus->dtype = newdtype;
        focus = focus->next;
    }
}

void apply_indirection(struct symboltable *st){
    struct node* focus = st->root;
    while(focus){
        char *newdtype = (char *)malloc(strlen(focus->dtype)+2);
        newdtype[0] = '\0';
        strcat(newdtype,"*");
        strcat(newdtype,focus->dtype);
        free(focus->dtype);
        focus->dtype = newdtype;
        focus = focus->next;
    }
}

char *dstring(struct symboltable *st){
    struct node *focus = st->root;
    int len = 0;
    while(focus){
        len+=strlen(focus->dtype);
        len++;
        focus = focus->next;
    }
    if(!len)
        return strdup("");
    char *ans = (char *)malloc(len+2);
    strcpy(ans,"(");
    focus = st->root;
    while(focus){
        strcat(ans,focus->dtype);
        strcat(ans,",");
        focus=focus->next;
    }
    ans[len] = ')';
    ans[len+1] = '\0';
    return ans;
}

char *tstring(struct symboltable *st){
    struct node *focus = st->root;
    int len = 0;
    while(focus){
        len+=strlen(focus->id);
        len++;
        focus = focus->next;
    }
    if(!len)
        return strdup("");
    char *ans = (char *)malloc(len);
    focus = st->root;
    ans[0] = '\0';
    while(focus){
        strcat(ans,focus->id);
        strcat(ans," ");
        focus = focus->next;
    }
    ans[len-1] = '\0';
    return ans;
}

void printsym(struct symboltable *st){
    struct node *focus = st->root;
    while(focus){
        printf("%s\t%d\t(%s)\n",focus->id,focus->line,focus->scope);
        focus = focus->next;
    }
}