#include "tac.h"
int tc = 0;
char* ia(int a){
    int num = 1;
    int ta = a/10;
    while(ta){
        num++;
        ta/=10;
    }
    char *answer = (char *)malloc(num+1);
    return itoa(a,answer,10);
}
char* mcat(int count, ...){
    va_list vl;
    va_start(vl,count);
    int n = 0;
    char *result = strdup("");
    for(int i = 0; i<count; i++){
        char *astr = strdup(va_arg(vl,char*));
        n+=strlen(astr);
        char *newresult = (char *)malloc(n+1);
        strcpy(newresult,result);
        strcat(newresult,astr);
        free(result);
        free(astr);
        result = newresult;
    }
    va_end(vl);
    return (char*)result;
}
char* tacagn(char *var){
    int tnum = tc++;
    char *result = (char *)mcat(4,"t",ia(tnum)," = ",var);
    return result;
}
char* sapp(char *dest, char* src){
    int n = strlen(dest),m = strlen(src);
    char *ans = (char *)malloc(n+m+1);
    strcpy(ans,dest);
    strcat(ans,src);
    return ans;
}
char* slastterm(char* tac){
    int n = strlen(tac);
    int pos = -1;
    for(int i = n-1; i>=0; i--){
        if(tac[i]==' '){
            pos = i+1;
            break;
        }
    }
    int len = 0;
    for(int i = pos; i<n; i++){
        if(tac[i]=='\n'||tac[i]==' '||tac[i]=='\0')
            break;
        len++;
    }
    char *answer = (char *)malloc(len+1);
    strncpy(answer,tac+pos,len);
    answer[len] = '\0';
    return answer;
}

char* lastterm(char *tac){
    int n = strlen(tac);
    int pos = 0;
    for(int i = n-1; i>=0; i--){
        if(tac[i] == '\n'){
            pos = i+1;
            break;
        }
    }
    int len = 0;
    for(int i = pos; i<n; i++){
        if(tac[i]==' '||tac[i]=='\0'||tac[i]=='\n')
            break;
        len++;
    }
    char *answer = (char *)malloc(len+1);
    strncpy(answer,tac+pos,len);
    answer[len] = '\0';
    return answer;
}

char *poplast(char* tac){
    int n = strlen(tac);
    int pos = 0;
    for(int i = n-1; i>=0; i--){
        if(tac[i]=='\n'){
            pos = i;
            break;
        }
    }
    char *answer = (char *)malloc(pos+1);
    if(pos)
        strncpy(answer,tac,pos);
    answer[pos] = '\0';
    return answer;
}

char *arrop(char *tac1, char *tac2){
    char *lt1 = lastterm(tac1),*lt2 = lastterm(tac2);
    int tnum = tc++;
    char *pts = ia(tnum);
    char *prebridge = mcat(5,"t",pts," = ",lt2, " * 4\n");
    tnum = tc++;
    char *ts = ia(tnum);
    char *bridge = mcat(7,"t",ts," = ",lt1," + t",pts,"\n");
    tnum = tc++;
    char* ts2 = ia(tnum);
    char *bridge2 = mcat(6,prebridge,bridge,"t",ts2," = *t",ts);
    return mcat(5,tac1,"\n",tac2,"\n",bridge2);
}

char *postfix(char *tac, char* op){
    char *lt = slastterm(tac);
    char *opstr = (char *)malloc(2);
    opstr[0] = op[0];
    opstr[1] = '\0';
    int tnum = tc++;
    char *ts = ia(tnum);
    char *tmptac = poplast(tac);
    if(strlen(tmptac))
        tmptac = sapp(tmptac,"\n");
    char* newtac = mcat(7, tmptac, lt, " = ", lt, " ", opstr," 1");
    if(opstr[0]=='+')
        opstr[0] = '-';
    else
        opstr[0] = '+';
    char* newtac2 = mcat(8, newtac, "\nt", ts, " = ", lt, " ", opstr, " 1");
    free(ts);
    free(opstr);
    free(newtac);
    free(tmptac);
    return newtac2;
}

char *prefix(char *tac, char* op){
    char *lt = slastterm(tac);
    char *opstr = (char *)malloc(2);
    opstr[0] = op[0];
    opstr[1] = '\0';
    int tnum = tc++;
    char *ts = ia(tnum);
    char *tmptac = poplast(tac);
    if(strlen(tmptac))
        tmptac = sapp(tmptac,"\n");
    char* newtac = mcat(7, tmptac, lt, " = ", lt, " ", opstr," 1");
    char* newtac2 = mcat(5, newtac, "\nt", ts, " = ", lt);
    free(ts);
    free(opstr);
    free(newtac);
    free(tmptac);
    return newtac2;
}

char *unary(char *tac, char* op){
    char *lt = lastterm(tac);
    int tnum = tc++;
    char *ts = ia(tnum);
    char* tmptac = strdup(tac);
    if(strlen(tmptac))
        tmptac = sapp(tmptac,"\n");
    char* newtac = mcat(6, tmptac, "t", ts, " = ", op, lt);
    free(ts);
    free(tmptac);
    return newtac;
}

char *binop(char *tac1, char *tac2, char *op){
    char *lt1 = lastterm(tac1),*lt2 = lastterm(tac2);
    int tnum = tc++;
    char *ts = ia(tnum);
    char *newtac = mcat(11,tac1,"\n",tac2,"\nt",ts," = ",lt1," ",op," ",lt2);
    free(ts);
    return newtac;
}

char *assign(char *tac1, char *tac2, char *op){
    char *lt1 = slastterm(tac1),*lt2 = lastterm(tac2);
    char *t1 = poplast(tac1);
    int tnum = tc++;
    char *ts = ia(tnum);
    if(strlen(t1))
        t1 = sapp(t1,"\n");
    if(!strlen(op))
        return mcat(10,tac2,"\n",t1,lt1," = ",lt2,"\nt",ts," = ",lt1);
    return mcat(14,tac2,"\n",t1,lt1," = ",lt1," ",op," ",lt2,"\nt",ts," = ",lt1);
}