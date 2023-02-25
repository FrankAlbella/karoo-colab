package edu.uf.karoo_collab.module.battery;

import androidx.annotation.NonNull;

import java.util.Map;

import edu.uf.karoo_collab.MainActivity;
import io.hammerhead.sdk.v0.SdkContext;
import io.hammerhead.sdk.v0.datatype.Dependency;
import io.hammerhead.sdk.v0.datatype.transformer.SdkTransformer;

public class BatteryTransformer extends SdkTransformer {
    public BatteryTransformer(@NonNull SdkContext context) {
        super(context);
    }

    @Override
    public double onDependencyChange(long l, @NonNull Map<Dependency, Double> map) {
        MainActivity main = new MainActivity();
        return main.getBatteryLevel();
    }
}
