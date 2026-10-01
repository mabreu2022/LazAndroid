package com.lazarus.android.demo;

import android.app.NativeActivity;
import android.os.Bundle;
import android.util.Log;

public class MainActivity extends NativeActivity {
    private static final String TAG = "LazApp";

    static {
        try {
            Log.i(TAG, "Carregando libsqlite.so via System.loadLibrary...");
            System.loadLibrary("sqlite");
            Log.i(TAG, "libsqlite.so carregada com sucesso!");
        } catch (Throwable t) {
            Log.e(TAG, "Falha ao carregar libsqlite.so: " + t.getMessage(), t);
        }

        try {
            Log.i(TAG, "Carregando liblazapp.so via System.loadLibrary...");
            System.loadLibrary("lazapp");
            Log.i(TAG, "liblazapp.so carregada com sucesso!");
        } catch (Throwable t) {
            Log.e(TAG, "Falha ao carregar liblazapp.so: " + t.getMessage(), t);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
}
