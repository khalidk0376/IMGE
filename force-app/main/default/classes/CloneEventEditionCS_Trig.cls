/**
 * File:        CloneEventEditionCS_Trig.cls
 * Project:     GAP
 * Created Date: 10-06-2020
 * Created By:  Rajesh Kumar
 * Modified By:  Rajesh Kumar
 * Test Class:EventEditionTrigg_Test
 * Coverage: 
 *
 * *************************************************************************
 * @description This class is using in "Trigger Management app" Trigger. earlier it was use in saprate trigger (trgCloneEventEditionCS)
 * *************************************************************************
 * History:Ticket :BK-3756
 * Created/Modified By: Girikon(Archit, Aishwarya)
 * Created On:          06/11/2017
 *
*/

public with sharing class CloneEventEditionCS_Trig implements TriggerInterface_EventEdition.Runnable  {
    public void run(TriggerInterface_EventEdition.Trig trig){  
        //@description/Purpose: Inserting the related objects data/records when creating a new EventEdition record  
        triggersHandler handler = new triggersHandler();
        handler.CloneEventEditionCS(trig.NewMap);
    }
}