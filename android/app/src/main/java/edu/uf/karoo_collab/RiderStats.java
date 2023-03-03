package edu.uf.karoo_collab;

public class RiderStats {

    private static double myHR = 12.0;
    private static double myPower = 0.0;

    private static double partnerHR = 205.0;
    private static double partnerPower = 0.0;

    public static void setMyHR(double hr) {
       
        myHR = hr;
        System.out.println("setMyHR: myHR is set to: " + myHR);
    }

    public static double getMyHR() {
        System.out.println("myHR got as: " + myHR);
        return myHR;
    }

    public static void setMyPower(double power) {
        myPower = power;
    }

    public static double getMyPower() {
        return myPower;
    }

    public static void setPartnerHR(double hr) {
        partnerHR = hr;
        //System.out.println("partnerHR is set to: " + partnerHR);
    }
    public static double getPartnerHR()
    {
        return partnerHR;
    }
    public static void setPartnerPower(double power) {
        partnerPower = power;
    }
    public static double getPartnerPower()
    {
        return partnerPower;
    }


}
