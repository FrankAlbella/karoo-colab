package edu.uf.karoo_collab.module;

import androidx.annotation.NonNull;

import edu.uf.karoo_collab.module.battery.BatteryDataType;
import edu.uf.karoo_collab.module.pheartrate.PartnerHeartRateDataType;

import java.util.Arrays;
import java.util.List;

import io.hammerhead.sdk.v0.Module;
import io.hammerhead.sdk.v0.ModuleFactoryI;
import io.hammerhead.sdk.v0.SdkContext;
import io.hammerhead.sdk.v0.datatype.SdkDataType;

public class TestModule extends Module {
    public static ModuleFactoryI factory = new ModuleFactoryI() {
        @NonNull
        @Override
        public Module buildModule(@NonNull SdkContext sdkContext) {
            return new TestModule(sdkContext);
        }
    };

    public TestModule(@NonNull SdkContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getName() {
        return "Partner Info";
    }

    @NonNull
    @Override
    public String getVersion() {
        return "v0.0.0";
    }

    @NonNull
    @Override
    protected List<SdkDataType> provideDataTypes() {
        return Arrays.asList(
                new PartnerHeartRateDataType(getContext()),
                new BatteryDataType(getContext())
        );
    }
}
