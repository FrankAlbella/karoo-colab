package edu.uf.karoo_collab.module.battery;

import androidx.annotation.NonNull;

import io.hammerhead.sdk.v0.SdkContext;
import io.hammerhead.sdk.v0.datatype.SdkDataType;
import io.hammerhead.sdk.v0.datatype.formatter.BuiltInFormatter;
import io.hammerhead.sdk.v0.datatype.formatter.SdkFormatter;
import io.hammerhead.sdk.v0.datatype.transformer.SdkTransformer;
import io.hammerhead.sdk.v0.datatype.view.BuiltInView;
import io.hammerhead.sdk.v0.datatype.view.SdkView;

public class BatteryDataType extends SdkDataType {
    public BatteryDataType(@NonNull SdkContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getDescription() {
        return "Battery level of the Karoo";
    }

    @NonNull
    @Override
    public String getDisplayName() {
        return "Battery level (test)";
    }

    @NonNull
    @Override
    public String getTypeId() {
        return "better-level";
    }

    @NonNull
    @Override
    public SdkFormatter newFormatter() {
        return new BuiltInFormatter.Numeric(0);
    }

    @NonNull
    @Override
    public SdkTransformer newTransformer() {
        return new BatteryTransformer(getContext());
    }

    @NonNull
    @Override
    public SdkView newView() {
        return new BuiltInView.Numeric(getContext());
    }
}
