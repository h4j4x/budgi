package com.sp1ke.budgi.api.helper;

import com.sp1ke.budgi.api.category.domain.JpaCategory;
import com.sp1ke.budgi.api.wallet.domain.JpaWallet;

public record CategoryWalletWrapper(JpaCategory category, JpaWallet wallet, String userToken) {
}
