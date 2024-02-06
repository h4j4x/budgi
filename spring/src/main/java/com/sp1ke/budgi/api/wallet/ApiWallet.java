package com.sp1ke.budgi.api.wallet;

import java.io.Serializable;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Builder
@Getter
@Setter
public class ApiWallet implements Serializable {
    private String code;

    private String name;

    private WalletType walletType;
}
