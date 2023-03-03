package edu.uf.karoo_collab.module.pheartrate;

import edu.uf.karoo_collab.RiderStats;

import androidx.annotation.NonNull;

import java.util.Map;

import io.hammerhead.sdk.v0.SdkContext;
import io.hammerhead.sdk.v0.datatype.Dependency;
import io.hammerhead.sdk.v0.datatype.transformer.SdkTransformer;

public class PartnerHeartRateTransformer extends SdkTransformer {
    public PartnerHeartRateTransformer(@NonNull SdkContext context) {
        super(context);
    }

    @Override
    public double onDependencyChange(long l, @NonNull Map<Dependency, Double> map) {
        Double myHR = map.get(Dependency.HEART_RATE);

        //if(!(myHR == null || myHR == MISSING_VALUE))
           //RiderStats.setMyHR(myHR);

        // Double partnerHR = RiderStats.getPartnerHR();

        // System.out.println("Transformer: Dependency.HEART_RATE = " + myHR);
        // System.out.println("Transformer: MainActivity.getPartnerHR() = " + partnerHR);

        Double preset = 105.0;

        return RiderStats.getMyHR()+10;
    }
}
