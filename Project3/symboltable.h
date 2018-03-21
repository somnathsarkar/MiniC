struct node{
    char *id, *dtype;
    char *scope;
    int line;
    struct node* next;
};

struct symboltable{
    struct node* root;
};
struct symboltable *createsymboltable();
void add_identifier(struct symboltable* st, char* id, char* dtype);
void apply_scope(struct symboltable* st, char* scope);
struct node* lookup(struct symboltable* st, char *key);
void merge_table(struct symboltable* dest, struct symboltable *src, int check_conflict);
void assign_datatype(struct symboltable* st, char *dtype);
void apply_indirection(struct symboltable* st);
void printsym(struct symboltable* st);
char *dstring(struct symboltable *st);