#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
int main()
{
        // /usr/local/bin/kubectl get pods -o custom-columns=:metadata.name --no-headers=true --field-selector status.podIP=172.17.0.7 | xargs -I{} kubectl exec -i {} -- bash -c ls
        char *args[20];   
        args[0] = "/usr/local/bin/kubectl";
        args[1] = "get";
        args[2] = "pods";
        args[3] = "-o";
        args[4] = "custom-columns=:metadata.name";
        args[5] = "--no-headers=true";
        args[6] = "--field-selector";
        args[7] = "status.podIP=172.17.0.7";  
        args[8] = "|";
        args[9] = "xargs";
        args[10] = "-I{}";
        args[11] = "/usr/local/bin/kubectl";
        args[12] = "exec";
        args[13] = "-i";
        args[14] = "{}";
        args[15] = "--";
        args[16] = "bash";
        args[17] = "-c";
        args[18] = "ls";

        // args[10] = "-I{}";
        // args[11] = 
        // args[2] = "exec";
        // args[4] = "--";
        // args[5] = "bash";
        // //args[6] = "-c";
        // //args[7] = "/etc/fossology/mods-enabled/nomos/agent/nomos --scheduler_start --userID=0 --groupID=0 --scheduler_start --jobId=0";
        // args[6] = NULL;
        execv(args[0], args);

        printf("Ending-----");
      
    return 0;
}