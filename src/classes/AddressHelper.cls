/*
 * Revision: Version 1.0 
 * @author: Del Rosario, George
 * Date: 13/10/2015
 * Requirement/Project Name: Singapore Press Holdings
 * Description: Address format for all the templates except GIFT LETTER
 * Description: Address format for GIFT LETTER
 */

public class AddressHelper {
    
    public static String finalAddressOutput = '';
        
    //Start D-3722 VPernicia 10/20/15
     public static String formatAddress(Contact con, Boolean isAck, Boolean isPackingLabel){

        constructAddress(con, isAck, isPackingLabel);
        system.debug('gddr final output>>: ' + finalAddressOutput);
        return finalAddressOutput;

    }
    //End D-3722 VPernicia 10/20/15
    //Start D-3722 Gdelrosario 3/11/15
    public static String formatGiftAddress(Order_Line_Item_Gift__c olg){

        constructGiftAddress(olg);
        system.debug('gddr final GIFT output>>: ' + finalAddressOutput);
        return finalAddressOutput;

    }
    //Start D-3722 Gdelrosario 3/11/15
   
    
    //Start D-3722 VPernicia 10/20/15
    public static void constructAddress(Contact selectedContact, Boolean isAck, Boolean isPackingLabel){

        String address1 = '';
        String address2 = '';
        String address3 = '';
        String address4 = '';
        String address5 = '';
        String address6 = '';
        String finalAddress = '';

        
        if(selectedContact.Id != null){
            if(selectedContact.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Local')){                       
                String bhN = '';
                String stN = '';
                String lvN = '';
                String unitN = '';
                bhN = selectedContact.Address__r.Block_House_Number__c;
                stN = selectedContact.Address__r.Street_Name__c;
                if(bhN <> null && bhN <> 'null' && bhN <> ''){
                    address1 += bhN+' ';
                }
                if(stN <> null && stN <> 'null' && stN <> ''){
                    address1 += stN;
                }
                if((bhN <> null && bhN <> 'null' && bhN <> '')||( stN <> null && stN <> 'null' && stN <> '' )){
                    if (!isAck) { address1 += '<br/>'; } else { address1 += ', '; }
                }
                lvN = selectedContact.Address__r.Level_Number__c;
                unitN = selectedContact.Address__r.Unit_Number__c;
                if(lvN <> null && lvN <> 'null' && lvN <> ''){
                    address2 += '#'+lvN;
                }
                if(unitN <> null && unitN <> 'null' && unitN <> ''){
                    address2 += '-'+unitN;
                }
                if((lvN <> null && lvN <> 'null' && lvN <> '')||( unitN <> null && unitN <> 'null' && unitN <> '' )){
                    if (!isAck) { address2 += '<br/>'; } else { address2 += ', '; }
                }
                if(selectedContact.Address__r.Building_Name__c <> null){
                    address3 += selectedContact.Address__r.Building_Name__c;
                }
                if(selectedContact.Address__r.Building_Name__c <> null){
                    if (!isAck) { address3 += '<br/>'; } else { address3 += ', '; }
                }
                if(selectedContact.Address__r.Country__r.Country_Name__c <> null){
                    address4 += selectedContact.Address__r.Country__r.Country_Name__c;
                }
                if(selectedContact.Address__r.Postal_Code__r.Name <> null){
                    address4 += ' '+selectedContact.Address__r.Postal_Code__r.Name;
                }
            }
    
            if(selectedContact.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Overseas')){
                if(selectedContact.Address__r.Address_1__c <> null){
                    address1 = selectedContact.Address__r.Address_1__c;
                    if (!isAck) { address1 += '<br/>'; } else { address1 += ', '; }
                }
                if(selectedContact.Address__r.Address_2__c <> null){
                    address2 = selectedContact.Address__r.Address_2__c;
                    if (!isAck) { address2 += '<br/>'; } else { address2 += ', '; }
                }
                if(selectedContact.Address__r.Address_3__c <> null){
                    address3 = selectedContact.Address__r.Address_3__c;
                    if (!isAck) { address3 += '<br/>'; } else { address3 += ', '; }
                }
                if(selectedContact.Address__r.Address_4__c <> null){
                    address4 = selectedContact.Address__r.Address_4__c;
                    if (!isAck) { address4 += '<br/>'; } else { address4 += ', '; }
                    if (isPackingLabel) {address4 += '<br/>';}
                }               
                if(selectedContact.Address__r.Country__r.Country_Name__c <> null){
                    address5 = selectedContact.Address__r.Country__r.Country_Name__c;
                }
            }
    
            if(selectedContact.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Internal')){
                //START D-3529 Gdelrosario 14/10/2015 : change the address to standard field 
                // Start D-3722 VPernicia 11/4/15: Change field in the condition
                // Start D-3930 VPernicia 11/23/15
                if(selectedContact.Address__r.Section_Code__r.Name <> null){
                    address1 = selectedContact.Address__r.Section_Code__r.Name;
                    if (!isAck) { address1 += '<br/>'; } else { address1 += ', '; }
                }
                // End D-3930 VPernicia 11/23/15
                if(selectedContact.Address__r.Department__r.Name <> null){
                    address2 = selectedContact.Address__r.Department__r.Name;
                    if (!isAck) { address2 += '<br/>'; } else { address2 += ', '; }
                }
                if(selectedContact.Address__r.Division_Code__r.Name <> null){
                    address3 = selectedContact.Address__r.Division_Code__r.Name;
                    if (!isAck) { address3 += '<br/>'; } else { address3 += ', '; }
                }
                if(selectedContact.Address__r.Company_Code__r.Name <> null){
                    address4 = selectedContact.Address__r.Company_Code__r.Name;
                    if (!isAck) { address4 += '<br/>'; } else { address4 += ', '; }
                }
                if(selectedContact.Address__r.Location_Code__r.Name <> null){
                    address5 = selectedContact.Address__r.Location_Code__r.Name;
                    if (!isAck) { address5 += '<br/>'; } else { address5 += ', '; }
                }
                if(selectedContact.Address__r.Country__r.Country_Name__c <> null){
                    address6 = selectedContact.Address__r.Country__r.Country_Name__c;
                } 
               // End D-3722 VPernicia 11/4/15: Change field in the condition
               //END D-3529 Gdelrosario 14/10/2015 : change the address to standard field  
            }
    
            if(selectedContact.Address__r.RecordTypeId == ConstantsSLB.getKeyId('Address_Airline')){
                if(selectedContact.Address__r.City__r.City_Name__c <> null){
                    address1 += (selectedContact.Address__r.City__r.City_Name__c.length() > 40 ? selectedContact.Address__r.City__r.City_Name__c.subString(0,40) : selectedContact.Address__r.City__r.City_Name__c );
                    if (!isAck) { address1 += '<br/>'; } else { address1 += ', '; }
                }
                if(selectedContact.Address__r.Airline_Number__c <> null){
                    address2 = selectedContact.Address__r.Airline_Number__c;
                    if (!isAck) { address2 += '<br/>'; } else { address2 += ', '; }
                }
                if(selectedContact.Address__r.Flight_Number_1__c <> null){ 
                    address3 = selectedContact.Address__r.Flight_Number_1__c;
                    if (!isAck) { address3 += '<br/>'; } else { address3 += ', '; }
                }   
                if(selectedContact.Address__r.Flight_Number_2__c <> null){
                    address4 = selectedContact.Address__r.Flight_Number_2__c;
                    if (!isAck) { address4 += '<br/>'; } else { address4 += ', '; }
                }
                //START UD-3722 Gdelrosario : change the country from address to City
                 if(selectedContact.Address__r.City__r.Country__r.Country_Name__c <> null){
                    address5 = selectedContact.Address__r.City__r.Country__r.Country_Name__c;
                }
                //END UD-3722 Gdelrosario : change the country from address to City
            }       
                       
            if(address1 <> null && address1 <> '' && address1 <> 'null'){
                system.debug('gddr 1>>: '+ address1);
                finalAddress += address1;
            }
            if(address2 <> null && address2 <> '' && address2 <> 'null'){
                system.debug('gddr 2>>: '+ address2);
                finalAddress += address2;
            }
            if(address3 <> null && address3 <> '' && address3 <> 'null'){
                system.debug('gddr 3>>: '+ address3);
                finalAddress += address3;
            }
            if(address4 <> null && address4 <> '' && address4 <> 'null'){
                system.debug('gddr 4>>: '+ address4);
                finalAddress += address4;
            }
            if(address5 <> null && address5 <> '' && address5 <> 'null'){
                system.debug('gddr 5>>: '+ address5);
                finalAddress += address5;
            }
            if(address6 <> null && address6 <> '' && address6 <> 'null'){
                system.debug('gddr 6>>: '+ address6);
                finalAddress += address6;
            }
                     
        }
         
         finalAddressOutput=finalAddress;
        system.debug('gddr FINAL>>: '+ finalAddressOutput);
          
    }
    //End D-3722 VPernicia 10/20/15   
    //Start D-3722 Gdelrosario 3/11/15
     public static void constructGiftAddress(Order_Line_Item_Gift__c oligift){
            String address1 = '';
            String address2 = '';
            String address3 = '';
            String address4 = '';
            String address5 = '';  
            String finalGiftAddress = '';

            if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.recordType.developerName == 'Local'){
                        
                        String bhN = '';
                        String stN = '';
                        String lvN = '';
                        String unitN = '';
                        bhN = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Block_House_Number__c;
                        stN = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Street_Name__c;
                        if(bhN <> null && bhN <> 'null' && bhN <> ''){
                            address1 += bhN+' ';
                        }
                        if(stN <> null && stN <> 'null' && stN <> ''){
                            address1 += stN;
                        }
                        if((bhN <> null && bhN <> 'null' && bhN <> '')||( stN <> null && stN <> 'null' && stN <> '' )){
                            //recAddress1 = address1;
                            address1 += '&nbsp'+'<br/>';
                        }
                        lvN = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Level_Number__c;
                        unitN = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Unit_Number__c;
                        if(lvN <> null && lvN <> 'null' && lvN <> ''){
                            address2 += '#'+lvN;
                        }
                        if(unitN <> null && unitN <> 'null' && unitN <> ''){
                            address2 += '-'+unitN;
                        }
                        
                        if((lvN <> null && lvN <> 'null' && lvN <> '')||( unitN <> null && unitN <> 'null' && unitN <> '' )){
                            //recAddress2 = address2;
                            address2 += ' ';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Building_Name__c <> null){
                            address3 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Building_Name__c;
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Building_Name__c == null){
                            address3 = ' '+'&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Building_Name__c <> null){
                            address3 += '&nbsp'+'<br/>';
                        }
                        
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c <> null){
                            address4 += oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c;
                           
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name <> null){
                            address4 += ' '+oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Postal_Code__r.Name;
                            
                        }
                    }

                    if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.recordType.developerName == 'Overseas'){
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_1__c <> null){
                            address1 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_1__c + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_2__c <> null){
                            address2 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_2__c + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_3__c <> null){
                            address3 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_3__c + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_4__c <> null){
                            address4 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Address_4__c + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c <> null){
                            address5 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Country__r.Country_Name__c;
                        }
                    }

                    if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.recordType.developerName == 'Internal'){
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Section_Name__c <> null){
                            address1 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Section_Code__r.Name + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Department_Name__c <> null){
                            address2 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Department__r.Name + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Division_Code__r.Name <> null){
                            address3 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Division_Code__r.Name + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Company_Name__c <> null){
                            address4 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Company_Code__r.Name + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Location_Name__c <> null){
                            address5 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Location_Code__r.Name;
                        }
                    }

                    if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.recordType.developerName == 'Airline'){
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c <> null){
                            address1 += (oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c.length() > 40 ? oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c.subString(0,40) : oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.City_Name__c ) ;
                            address1 += '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Airline_Number__c <> null){
                            address2 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Airline_Number__c + '&nbsp'+'<br/>';
                        }
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_1__c <> null){    
                            address3 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_1__c + '&nbsp'+'<br/>';
                        }   
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_2__c <> null){
                            address4 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.Flight_Number_2__c + '&nbsp'+'<br/>';
                        }
                        //Start UD-2517 VPernicia 08/27/15
                        if(oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__r.Country_Name__c <> null){
                            address5 = oligift.Order_Line_Item__r.Order__r.Recipient_Contact__r.Address__r.City__r.Country__c;
                        }
                        //End UD-2517 VPernicia 08/27/15
                    }

                    if(address1 <> null && address1 <> '' && address1 <> 'null'){
                        finalGiftAddress += address1;
                    }
                    if(address2 <> null && address2 <> '' && address2 <> 'null'){
                        finalGiftAddress += address2;
                    }
                    if(address3 <> null && address3 <> '' && address3 <> 'null'){
                        finalGiftAddress += address3;
                    }
                    if(address4 <> null && address4 <> '' && address4 <> 'null'){
                        finalGiftAddress += address4;
                    }
                    if(address5 <> null && address5 <> '' && address5 <> 'null'){
                        finalGiftAddress += address5;
                    }
                           
            finalAddressOutput=finalGiftAddress;
        }
        //Start D-3722 Gdelrosario 3/11/15



}