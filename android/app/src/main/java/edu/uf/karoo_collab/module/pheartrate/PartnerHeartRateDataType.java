package edu.uf.karoo_collab.module.pheartrate;

import androidx.annotation.NonNull;

import java.util.Arrays;
import java.util.List;

import io.hammerhead.sdk.v0.SdkContext;
import io.hammerhead.sdk.v0.datatype.Dependency;
import io.hammerhead.sdk.v0.datatype.SdkDataType;
import io.hammerhead.sdk.v0.datatype.formatter.BuiltInFormatter;
import io.hammerhead.sdk.v0.datatype.formatter.SdkFormatter;
import io.hammerhead.sdk.v0.datatype.transformer.SdkTransformer;
import io.hammerhead.sdk.v0.datatype.view.BuiltInView;
import io.hammerhead.sdk.v0.datatype.view.SdkView;

public class PartnerHeartRateDataType extends SdkDataType {
    public PartnerHeartRateDataType(@NonNull SdkContext context) {
        super(context);
    }

    @NonNull
    @Override
    public String getDescription() {
        return "Heart rate of your partner";
    }

    @NonNull
    @Override
    public String getDisplayName() {
        return "Partner HR";
    }

    @NonNull
    @Override
    public String getTypeId() {
        return "partner-hr";
    }

    @NonNull
    @Override
    public List<Dependency> getDependencies() {
        return Arrays.asList(Dependency.HEART_RATE);
    }

    @NonNull
    @Override
    public SdkFormatter newFormatter() {
        return new BuiltInFormatter.Numeric(0);
    }

    @NonNull
    @Override
    public SdkTransformer newTransformer() {
        return new PartnerHeartRateTransformer(getContext());
    }

    @NonNull
    @Override
    public SdkView newView() {
        return new BuiltInView.Numeric(getContext());
    }
}
