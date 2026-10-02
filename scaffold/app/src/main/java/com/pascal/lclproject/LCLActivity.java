package com.pascal.lclproject;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.text.InputType;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.FrameLayout;
import java.util.ArrayList;

/**
 * LazDroid LCLActivity
 * Camada de comunicação Java/Android para aplicações Lazarus LCL CustomDrawn.
 * Incorpora renderização de alta densidade (DPI), controle de Safe Area (insets),
 * captura avançada de teclado virtual (IME) e tratamento robusto de ciclo de vida.
 */
public class LCLActivity extends Activity {
    private static final String TAG = "LazDroid";
    private static boolean crashLoggerInstalled = false;

    // Campos exportados para o runtime Pascal da LCL
    public String lcltext = "";
    public String lcltitle = "";
    public String lclbutton1str = "";
    public String lclbutton2str = "";
    public String lclbutton3str = "";
    public int lclwidth = 0;
    public int lclheight = 0;
    public int lclbutton1 = 0;
    public int lclbutton2 = 0;
    public int lclbutton3 = 0;
    public Bitmap lclbitmap = null;
    public int lcltextsize = 16;
    public int lcltextascent = 0;
    public int lcltextbottom = 0;
    public int lcltextdescent = 0;
    public int lcltextleading = 0;
    public int lcltexttop = 0;
    public int lclmaxwidth = 0;
    public int lclmaxcount = 0;
    public float[] lclpartialwidths = null;
    public int lcltimerinterval = 0;
    public Runnable lcltimerid = null;
    public int lclxdpi = 160;
    public int lclydpi = 160;
    public int lclformwidth = 0;
    public int lclformheight = 0;
    public int lclscreenwidth = 0;
    public int lclscreenheight = 0;
    public String lcldestination = "";
    public int lclkind = 0;
    public String[] lclmenu_captions = null;

    // Configurações de renderização
    // Modo Nativo: LCL desenha no DPI físico do aparelho
    // Modo Compositor: LCL desenha em resolução base e o Android escala via hardware
    private static final boolean LAZDROID_NATIVE_RENDER = true;
    private static final int LAZDROID_DESIGN_WIDTH = 360;
    private static final int LAZDROID_DESIGN_HEIGHT = 640;

    private Handler handler = new Handler();
    private Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private LCLView lclView;
    private int mDesignWidth = 0;
    private int mDesignHeight = 0;
    private final ArrayList<Runnable> timers = new ArrayList<Runnable>();

    static {
        // Carrega bibliotecas C/Pascal
        try {
            try {
                System.loadLibrary("sqlite");
                Log.i(TAG, "libsqlite.so carregada.");
            } catch (Throwable t) {
                // opcional
            }
            try {
                System.loadLibrary("lazapp");
                Log.i(TAG, "liblazapp.so carregada com sucesso.");
            } catch (Throwable t1) {
                try {
                    System.loadLibrary("project1");
                    Log.i(TAG, "libproject1.so carregada com sucesso.");
                } catch (Throwable t2) {
                    Log.w(TAG, "Nao foi possivel carregar liblazapp/libproject1: " + t2.getMessage());
                }
            }
            Log.i(TAG, "Bibliotecas nativas inicializadas.");
        } catch (UnsatisfiedLinkError e) {
            Log.e(TAG, "Falha fatal ao carregar bibliotecas nativas: " + e.getMessage(), e);
        }
    }

    private static synchronized void installCrashLogger() {
        if (crashLoggerInstalled) return;
        crashLoggerInstalled = true;
        final Thread.UncaughtExceptionHandler previous = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread thread, Throwable error) {
                Log.e(TAG, "Excecao Java nao tratada na thread " + thread.getName(), error);
                if (previous != null) {
                    previous.uncaughtException(thread, error);
                }
            }
        });
    }

    // Métodos nativos implementados em Pascal (customdrawnobject_android.inc)
    public native int LCLDrawToBitmap(int width, int height, Bitmap bitmap);
    public native int LCLOnTouch(float x, float y, int action);
    public native int LCLOnCreate(Activity activity);
    public native int LCLOnMessageBoxFinished(int result, int dialogType);
    public native int LCLOnKey(int action, int keyCode, KeyEvent event, int unicodeChar);
    public native int LCLOnTimer(Runnable timer, int id);
    public native int LCLOnConfigurationChanged(int newDpi, int newWidth);
    public native int LCLOnSensorChanged(int sensor, double[] values);
    public native int LCLOnMenuAction(int item, int checked);

    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        installCrashLogger();
        Log.i(TAG, "onCreate: package=" + getPackageName() + ", pid=" + android.os.Process.myPid());

        // Flags para manter a tela ativa em depuração
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
        } else {
            getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            );
        }
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        lclView = new LCLView(this);

        // FrameLayout raiz com setFitsSystemWindows: respeita status bar, notch e navegação
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);
        root.setFitsSystemWindows(true);
        root.addView(lclView, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        setContentView(root);

        // Executa LCLOnCreate após o primeiro layout da View, garantindo medidas reais
        lclView.post(new Runnable() {
            @Override
            public void run() {
                updateDesignSize(lclView.getWidth(), lclView.getHeight());
                Log.i(TAG, "LCLOnCreate: view " + lclView.getWidth() + "x" + lclView.getHeight() +
                        ", surface " + lclscreenwidth + "x" + lclscreenheight + ", dpi " + lclxdpi);
                int result = LCLOnCreate(LCLActivity.this);
                Log.i(TAG, "LCLOnCreate retornou " + result);
                lclView.invalidate();
            }
        });
    }

    private void updateDesignSize(int viewWidth, int viewHeight) {
        viewWidth = Math.max(1, viewWidth);
        viewHeight = Math.max(1, viewHeight);

        DisplayMetrics metrics = getResources().getDisplayMetrics();
        int dpi = metrics.densityDpi > 0 ? metrics.densityDpi : (int) metrics.xdpi;
        if (dpi <= 0) dpi = 160;

        int designWidth = viewWidth;
        int designHeight = viewHeight;

        if (!LAZDROID_NATIVE_RENDER) {
            int designShort = Math.min(LAZDROID_DESIGN_WIDTH, LAZDROID_DESIGN_HEIGHT);
            if (viewWidth <= viewHeight) {
                designWidth = designShort;
                designHeight = Math.round((float) designShort * viewHeight / viewWidth);
            } else {
                designHeight = designShort;
                designWidth = Math.round((float) designShort * viewWidth / viewHeight);
            }
        }

        mDesignWidth = designWidth;
        mDesignHeight = designHeight;
        lclformwidth = designWidth;
        lclformheight = designHeight;
        lclscreenwidth = designWidth;
        lclscreenheight = designHeight;
        lclxdpi = dpi;
        lclydpi = dpi;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (lclView != null) lclView.invalidate();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        Log.i(TAG, "onDestroy");
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration config) {
        super.onConfigurationChanged(config);
        Log.i(TAG, "onConfigurationChanged: orientation=" + config.orientation);
        if (lclView != null) {
            lclView.post(new Runnable() {
                @Override
                public void run() {
                    updateDesignSize(lclView.getWidth(), lclView.getHeight());
                    LCLOnConfigurationChanged(lclxdpi, lclformwidth);
                    lclView.invalidate();
                }
            });
        }
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        int result = LCLOnKey(event.getAction(), event.getKeyCode(), event, event.getUnicodeChar());
        if ((result & 1) != 0 && lclView != null) {
            lclView.invalidate();
        }
        // Bit 2: LCL tratou o botão BACK no form principal e solicita mover o app para background
        if (((result & 2) != 0) && (event.getAction() == KeyEvent.ACTION_UP)) {
            moveTaskToBack(true);
            return true;
        }
        if (result != 0) {
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    public void LCLDoGetTextBounds() {
        textPaint.setTextSize(lcltextsize);
        Rect bounds = new Rect();
        textPaint.getTextBounds(lcltext, 0, lcltext.length(), bounds);
        Paint.FontMetricsInt fm = textPaint.getFontMetricsInt();
        lclwidth = Math.max(1, (int) Math.ceil(textPaint.measureText(lcltext)));
        lclheight = Math.max(1, fm.bottom - fm.top);
        lcltextascent = fm.ascent;
        lcltextbottom = fm.bottom;
        lcltextdescent = fm.descent;
        lcltextleading = fm.leading;
        lcltexttop = fm.top;
    }

    public void LCLDoGetTextPartialWidths() {
        textPaint.setTextSize(lcltextsize);
        lclpartialwidths = new float[lcltext.length()];
        textPaint.getTextWidths(lcltext, lclpartialwidths);
    }

    public void LCLDoDrawText(int color) {
        LCLDoGetTextBounds();
        lclbitmap = Bitmap.createBitmap(lclwidth, lclheight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(lclbitmap);
        textPaint.setColor(color);
        textPaint.setTextSize(lcltextsize);
        canvas.drawText(lcltext, 0, -lcltexttop, textPaint);
    }

    public void LCLDoShowMessageBox() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(lcltitle);
        builder.setMessage(lcltext);
        if (lclbutton1str != null && !lclbutton1str.isEmpty()) {
            builder.setPositiveButton(lclbutton1str, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    LCLOnMessageBoxFinished(lclbutton1, 0);
                }
            });
        }
        if (lclbutton2str != null && !lclbutton2str.isEmpty()) {
            builder.setNegativeButton(lclbutton2str, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    LCLOnMessageBoxFinished(lclbutton2, 0);
                }
            });
        }
        builder.show();
    }

    public void LCLDoCreateTimer() {
        final Runnable timer = new Runnable() {
            public void run() {
                LCLOnTimer(this, 0);
                if (lclView != null) lclView.invalidate();
                handler.postDelayed(this, Math.max(1, lcltimerinterval));
            }
        };
        lcltimerid = timer;
        timers.add(timer);
        handler.postDelayed(timer, Math.max(1, lcltimerinterval));
    }

    public void LCLDoDestroyTimer() {
        if (lcltimerid != null) {
            handler.removeCallbacks(lcltimerid);
            timers.remove(lcltimerid);
        }
    }

    public void LCLDoHideVirtualKeyboard() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null && lclView != null) {
            imm.hideSoftInputFromWindow(lclView.getWindowToken(), 0);
        }
    }

    public void LCLDoShowVirtualKeyboard() {
        if (lclView == null) return;
        lclView.requestFocus();
        int margin = Math.max(48, lclView.getHeight() / 6);
        Rect focusRect = new Rect(Math.max(0, lclView.lastTouchX - margin),
                                  Math.max(0, lclView.lastTouchY - margin),
                                  Math.min(lclView.getWidth(), lclView.lastTouchX + margin),
                                  Math.min(lclView.getHeight(), lclView.lastTouchY + margin));
        lclView.requestRectangleOnScreen(focusRect, false);
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.showSoftInput(lclView, InputMethodManager.SHOW_IMPLICIT);
        }
    }

    public void LCLDoStartReadingAccelerometer() {}
    public void LCLDoStopReadingAccelerometer() {}
    public void LCLDoSendMessage() { if (lclView != null) lclView.invalidate(); }
    public void LCLDoRequestPositionInfo() {}
    public void LCLDoShowListViewDialog() {}

    /**
     * LCLView — Superfície de renderização gráfica acelerada por hardware
     */
    private class LCLView extends View {
        private Bitmap bitmap;
        private final Paint scaledBitmapPaint = new Paint(Paint.FILTER_BITMAP_FLAG);
        private String composingText = "";
        public int lastTouchX = 0;
        public int lastTouchY = 0;

        public LCLView(Context context) {
            super(context);
            setFocusable(true);
            setFocusableInTouchMode(true);
            requestFocus();
        }

        @Override
        public boolean onCheckIsTextEditor() {
            return true;
        }

        private void dispatchCommittedText(CharSequence text) {
            if (text == null || text.length() == 0) return;
            for (int offset = 0; offset < text.length();) {
                int codePoint = Character.codePointAt(text, offset);
                KeyEvent event = new KeyEvent(KeyEvent.ACTION_MULTIPLE, KeyEvent.KEYCODE_UNKNOWN);
                LCLOnKey(-1, KeyEvent.KEYCODE_UNKNOWN, event, codePoint);
                offset += Character.charCount(codePoint);
            }
            invalidate();
        }

        private void dispatchDeleteKey() {
            long now = SystemClock.uptimeMillis();
            KeyEvent event = new KeyEvent(now, now, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL, 0);
            LCLOnKey(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_DEL, event, 0);
            invalidate();
        }

        @Override
        public InputConnection onCreateInputConnection(EditorInfo outAttrs) {
            outAttrs.inputType = InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_MULTI_LINE |
                    InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD;
            outAttrs.imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI | EditorInfo.IME_ACTION_NONE;
            return new BaseInputConnection(this, false) {
                @Override
                public boolean commitText(CharSequence text, int newCursorPosition) {
                    String value = text == null ? "" : text.toString();
                    if (!value.equals(composingText)) {
                        dispatchCommittedText(value);
                    }
                    composingText = "";
                    return true;
                }

                @Override
                public boolean setComposingText(CharSequence text, int newCursorPosition) {
                    String value = text == null ? "" : text.toString();
                    int common = 0;
                    int limit = Math.min(composingText.length(), value.length());
                    while (common < limit && composingText.charAt(common) == value.charAt(common)) {
                        common++;
                    }
                    for (int index = composingText.length(); index > common; index--) {
                        dispatchDeleteKey();
                    }
                    if (common < value.length()) {
                        dispatchCommittedText(value.substring(common));
                    }
                    composingText = value;
                    return true;
                }

                @Override
                public boolean finishComposingText() {
                    composingText = "";
                    return true;
                }

                @Override
                public boolean deleteSurroundingText(int beforeLength, int afterLength) {
                    if (beforeLength > 0) {
                        dispatchDeleteKey();
                    }
                    if (beforeLength > 0 && composingText.length() > 0) {
                        int newLength = Math.max(0, composingText.length() - 1);
                        composingText = composingText.substring(0, newLength);
                    }
                    return true;
                }

                @Override
                public boolean sendKeyEvent(KeyEvent event) {
                    if (event == null) return false;
                    if (event.getKeyCode() == KeyEvent.KEYCODE_DEL) {
                        if (event.getAction() == KeyEvent.ACTION_DOWN) {
                            dispatchDeleteKey();
                        }
                        return true;
                    }
                    LCLOnKey(event.getAction(), event.getKeyCode(), event, event.getUnicodeChar());
                    invalidate();
                    return true;
                }
            };
        }

        @Override
        protected void onSizeChanged(int width, int height, int oldWidth, int oldHeight) {
            super.onSizeChanged(width, height, oldWidth, oldHeight);
            if (width <= 0 || height <= 0) return;
            updateDesignSize(width, height);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);
            int width = Math.max(1, getWidth());
            int height = Math.max(1, getHeight());
            int designWidth = Math.max(1, mDesignWidth);
            int designHeight = Math.max(1, mDesignHeight);

            if (bitmap == null || bitmap.getWidth() != designWidth || bitmap.getHeight() != designHeight) {
                bitmap = Bitmap.createBitmap(designWidth, designHeight, Bitmap.Config.ARGB_8888);
            }

            LCLDrawToBitmap(designWidth, designHeight, bitmap);

            if (designWidth == width && designHeight == height) {
                canvas.drawBitmap(bitmap, 0, 0, null);
            } else {
                Rect source = new Rect(0, 0, designWidth, designHeight);
                Rect destination = new Rect(0, 0, width, height);
                canvas.drawBitmap(bitmap, source, destination, scaledBitmapPaint);
            }
        }

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            lastTouchX = Math.round(event.getX());
            lastTouchY = Math.round(event.getY());
            float width = Math.max(1, getWidth());
            float height = Math.max(1, getHeight());
            float designWidth = Math.max(1, mDesignWidth);
            float designHeight = Math.max(1, mDesignHeight);
            float x = event.getX() * designWidth / width;
            float y = event.getY() * designHeight / height;
            LCLOnTouch(x, y, event.getAction());
            invalidate();
            return true;
        }
    }
}
