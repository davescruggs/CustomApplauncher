public with sharing class AppHelper {
    public String app {get; set;}
    public List<User> userList {get; set;}
    
    public List<AppMenuItem> getApps() {
        List<SetupEntityAccess> seas = [SELECT SetupEntityId FROM SetupEntityAccess WHERE ParentId IN
                                        (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserID())
                                       ];

        system.debug('seas: ' + seas);
        
        Id[] sids = new List<Id>();
        for (SetupEntityAccess sea : seas){
                    sids.add(sea.SetupEntityId);
        }
        system.debug('sids: ' + sids);
        List<AppMenuItem> apps = [SELECT id, name, Label, StartURL, LogoURL, Type
                                FROM AppMenuItem 
                                WHERE id in :sids order by SortOrder ASC];
        system.debug('apps: ' + apps);
        return apps;
    }
    
    public PageReference getEntitlements() {
        listEntitlements( app );
        
        return null;
    }
    
    public List<User> listEntitlements(string appName){
        List<AppMenuItem> adminApproveds = [SELECT isUsingAdminAuthorization FROM AppMenuItem where Type = 'ConnectedApplication'and name = :appName];
        System.debug('AA Count: ' + adminApproveds.size() );
        List<User> users = new List<User>();
        for (AppMenuItem aa:adminApproveds){
            if(aa.isUsingAdminAuthorization){
      //          List<AppMenuItem> amt = [SELECT Id FROM AppMenuItem where Type = 'ConnectedApplication' and isUsingAdminAuthorization = true and name = :appName];
                List<AppMenuItem> amt = [SELECT Id FROM AppMenuItem where Type = 'ConnectedApplication' and name = :appName];
                Set<id> ids = new Set<id>();
                for (AppMenuItem sea:amt){
                    ids.add(sea.Id);
                }
                List<SetupEntityAccess> psIds = [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityId IN :ids];
                Set<id> ids1 = new Set<id>();
                for (SetupEntityAccess sea:psIds){
                    ids1.add(sea.ParentId);
                }
                List<PermissionSetAssignment> psAIds = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :ids1];
                List<Id> psUserIds = new List<Id>();
                for (PermissionSetAssignment sea:psAIds){
                    System.debug('UserIds : ' + sea.AssigneeId);
                    psUserIds.add(sea.AssigneeId);
                }
                
                System.debug('Count***** : ' + psAIds.size());
                users = [SELECT Id, Name, Username FROM USER where Id IN :ids OR Id IN :psUserIds];
                System.debug('Assigned Users: '+ users);
            }
            else{
                // should be getting self-approved? Guess that's everyone?
                users = [SELECT Id, Name, Username from User];
                System.debug('Self-Assigned Users : ' + users);
            }
        }
        System.debug('All Users: ' + users);
        return (userList = users);
    }
}