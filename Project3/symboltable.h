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
void add_identifier(struct symboltable* st, char* id, char* dtype,char* scope);
void apply_scope(struct symboltable* st, char* scope);
int lookup(struct symboltable* st, char *key);
void merge_table(struct symboltable* dest, struct symboltable *src);
