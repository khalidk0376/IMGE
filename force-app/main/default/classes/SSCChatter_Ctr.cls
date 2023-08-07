Public class SSCChatter_Ctr {
    public String OppId {get;set;}
    public SSCChatter_Ctr(){
        OppId = ApexPages.currentPage().getParameters().get('Id');
    }
}