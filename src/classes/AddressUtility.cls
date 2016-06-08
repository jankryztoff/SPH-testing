/**
 * Trigger Name: AddressUtility
 * Author: Kevin Evasco
 * Date: 09/26/2014
 * Project/Requirement: SPH
 * Description: This class contains reusable utility methods for the Address__c Object.
 * History: 09/26/2014 Kevin Evasco Created Utility
 */

public class AddressUtility 
{
    public static String concatenateAddressFields(String streetName, String buildingName, String blockHouseNumber, String levelNumber, String unitNumber, String postalCode)
    {
        String result = '';
        
        if(streetName != null && streetName != 'null' && streetName != '')
        {            
            result += streetName;
        }   
        result += ' ';
        
        if(buildingName != null && buildingName != 'null' && buildingName != '')
        {            
            result += buildingName;
        }   
        result += ' ';
        
        if(blockHouseNumber != null && blockHouseNumber != 'null' && blockHouseNumber != '')
        {            
            result += blockHouseNumber;
        }   
        result += ' ';
        
        if(levelNumber != null && levelNumber != 'null' && levelNumber != '')
        {            
            result += levelNumber;
        }   
        result += ' ';
        
        if(unitNumber != null && unitNumber != 'null' && unitNumber != '')
        {            
            result += unitNumber;
        }   
        result += ' ';
        
        if(postalCode != null && postalCode != 'null' && postalCode != '')
        {            
            result += postalCode;
        }   
        
        return result;
    }    
    
    public static String concatenateAddressFields2(String blockHouseNumber, String levelNumber, String unitNumber, String postalCode)
    {
        String result = '';        
        
        if(blockHouseNumber != null && blockHouseNumber != 'null' && blockHouseNumber != '')
        {            
            result += blockHouseNumber;
        }   
        result += ' ';
        
        if(levelNumber != null && levelNumber != 'null' && levelNumber != '')
        {            
            result += levelNumber;
        }   
        result += ' ';
        
        if(unitNumber != null && unitNumber != 'null' && unitNumber != '')
        {            
            result += unitNumber;
        }   
        result += ' ';
        
        if(postalCode != null && postalCode != 'null' && postalCode != '')
        {            
            result += postalCode;
        }   
        
        return result;
    }    
    
    public static String constructSingpostUniqueKey(String postalCode, String floor, String unit)
    {
        String result = '';        
        
        if(postalCode != null && postalCode != 'null' && postalCode != '')
        {            
            result += postalCode;
        }   
        result += ' ';
        
        if(floor != null && floor != 'null' && floor != '')
        {            
            result += floor;
        }   
        result += ' ';
        
        if(unit != null && unit != 'null' && unit != '')
        {            
            result += unit;
        }   
        
        return result;
    }    
}