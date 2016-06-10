public class ListObjectsContr {
    
    public String[] objects {
        get {
            String[] objectList = new String[]{};
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for (Schema.SObjectType obj : gd.values()) {
                objectList.add(String.valueOf(obj));
            }
            return objectList;
        }
        set;
    }
}