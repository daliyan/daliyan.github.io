---
title: Saving Android View state correctly
id: 45
categories:
  - android share
date: 2015-05-17 10:05:45
tags:
---

原文地址：http://trickyandroid.com/saving-android-view-state-correctly/

Today we will talk about saving and restoring View states in Android. I intentionally want to keep our focus on Android **Views** state just because I found this process just a little bit trickier than saving your `Activity` or `Fragment` state. Plus I think I've seen enough of re-invented wheels (sometimes really ugly ones) throughout the internet.

### Why do we need to save View state?

Very good question! I have very strong belief that mobile application should help you solve existing problems, not add new ones. 
Imagine a very complicated settings page: 
![Page](http://trickyandroid.com/content/images/2014/10/settings.jpg)This sample is not really a mobile device screenshot, but good for illustration purposes :) 
You have a lot of text fields, checkboxes, switches, etc. And you spent ~15 minutes trying to fill in all these fields. You almost there - almost hit that shiny _"Done"_ button, but accidentally you rotate the screen and... wait for it.... your changes **gone**. Everything is back to its original state.

Sure, there is a subset of users who just love your app no matter what (your mom maybe) and will be happy to take another round completing your form. But let's be honest to oureselves - it is the right path to be uninstalled right away (or even worse - mad croud of users with torches and pitchforks start ringing your doorbell).

So let's do the right thing and help our users! That's right! We need to save user's changes until user exlicitly asks us not to.

### How do I save a View state?

Let's have a simple layout with image, text and 1 `Switch` toggle:
<pre>&lt;LinearLayout  
    xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)"
    android:layout_width="match_parent"  
    android:layout_height="match_parent"  
    android:orientation="horizontal"  
    android:padding="@dimen/activity_horizontal_margin"&gt;  
    &lt;ImageView  
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"  
        android:src="@drawable/ic_launcher"/&gt;  
    &lt;TextView  
        android:layout_width="0dip"
        android:layout_weight="1"  
        android:layout_height="wrap_content"  
        android:text="My Text"/&gt;  
    &lt;Switch  
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"  
        android:layout_margin="8dip"/&gt;  
&lt;/LinearLayout&gt;</pre>

Super simple layout as you can see. But now when I switch toggle and then change screen orientation - my toggle is back to its original state :(

Android usually saves states of such views automatically. But why it didn't work in our case?

Let's take a step back and try to figure out how does Android manage View states. Here is what the normal save/restore process looks like: 
![](http://trickyandroid.com/content/images/2014/11/Screen-Shot-2014-11-02-at-12-22-46-PM.png)

*   `saveHierarchyState(SparseArray&lt;Parcelable&gt; container)` - called by Android framework whenever state needs to be saved. Normally calls`dispatchSaveInstanceState()`.
*   `dispatchSaveInstanceState(SparseArray&lt;Parcelable&gt; container)` - called by`saveHierarchyState()`. Internally it calls `onSaveInstanceState()` and expects`Parcelable` to be returned as a representation of current state. This `Parcelable`is stored in `container` (see input param) - key-value map. **View's ID** is taken as a key and `Parcelable` is taken as a value. Also if this is a `ViewGroup` - goes through its children and saves their state as well.
*   `Parcelable onSaveInstanceState()` - called by `dispatchSaveInstanceState()`. This method should be overridden by View's implementation to return actual View state.
*   `restoreHierarchyState(SparseArray&lt;Parcelable&gt; container)` - called by Android whenever state needs to be restored. Again, as an input parameter we have a`SparseArray` which contains all the states saved during the _save_ process.
*   `dispatchRestoreInstanceState(SparseArray&lt;Parcelable&gt; container)` - called by`restoreHierarchyState()`. Looks up Parcelable based on the View ID and passes it into `onRestoreInstanceState()`. If this is a `ViewGroup` - restores its children state as well.
*   `onRestoreInstanceState(Parcelable state)` - called by`dispatchRestoreInstanceState()`. State for this View ID is passed into this function if it is present in container.

The really **important** part of understanding this process is that `container` is shared for the entire view hierarchy. We will see why it is so important in a bit.

So now we know that since View's state is saved based on it's ID - _if View doesn't have an ID - it's state will not be saved into container_. There is no point of saving it - we will not be able to restore state anyways since we don't know which View this state belongs to.

Looks like that's the reason why our toggle state is not saved! Let's try to add an id to our toggle (and other views):
<pre>&lt;LinearLayout  
    xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)"
    android:layout_width="match_parent"  
    android:layout_height="match_parent"  
    android:orientation="horizontal"  
    android:padding="@dimen/activity_horizontal_margin"&gt;  
    &lt;ImageView  
        android:id="@+id/image"
        android:layout_width="wrap_content"  
        android:layout_height="wrap_content"  
        android:src="@drawable/ic_launcher"/&gt;  
    &lt;TextView  
        android:id="@+id/text"
        android:layout_width="0dip"  
        android:layout_weight="1"  
        android:layout_height="wrap_content"  
        android:text="My Text"/&gt;  
    &lt;Switch  
        android:id="@+id/toggle"
        android:layout_width="wrap_content"  
        android:layout_height="wrap_content"  
        android:layout_margin="8dip"/&gt;  
&lt;/LinearLayout&gt;</pre>

And here we go! It actually works! My state is preserved between configuration changes. Here is what our `SparseArray` looks like: 
![](http://trickyandroid.com/content/images/2014/11/Screen-Shot-2014-11-02-at-12-24-50-PM.png)

As you can see, each view which have an ID stores its state into `SparseArray`container. 
You ask how did it happen - we didn't actually provide any Parcelable as a state. And the answer is - Android took care of that. Android knows how to save state of it's built-in widgets.

In addition to ID, you should explicitly tell Android that your view wants to save its state. To do so - simply call **setSaveEnabled(true)**. You don't usually need to do this for built-in widgets, but if you develop custom view from scratch - you might need to enable it manually.
> To save View state at least 2 criterias should be met:
> 
> *   View should have an id
> *   **setSaveEnabled(true)** should be called

So now we know how to save state of built-in widgets. That's awesome, but what if we have some custom state and we want to preserve this state between configuration changes?

### Saving custom state

Now let's take a bit more complicated example. I want to extend my Switch and add my custom state to it:
<pre>public class CustomSwitch extends Switch {

    private int customState;

    .......

    public void setCustomState(int customState) {
        this.customState = customState;
    }  
}</pre>

Here is how I will be saving this state:
<pre>public class CustomSwitch extends Switch {

    private int customState;

    .............

    public void setCustomState(int customState) {
        this.customState = customState;
    }

    @Override
    public Parcelable onSaveInstanceState() {
        Parcelable superState = super.onSaveInstanceState();
        SavedState ss = new SavedState(superState);  
        ss.state = customState;  
        return ss;  
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        SavedState ss = (SavedState) state;
        super.onRestoreInstanceState(ss.getSuperState());  
        setCustomState(ss.state);  
    }

    static class SavedState extends BaseSavedState {
        int state;

        SavedState(Parcelable superState) {  
            super(superState);
        }

        private SavedState(Parcel in) {
            super(in);
            state = in.readInt();  
        }

        @Override
        public void writeToParcel(Parcel out, int flags) {
            super.writeToParcel(out, flags);
            out.writeInt(state);  
        }

        public static final Parcelable.Creator&lt;SavedState&gt; CREATOR
                = new Parcelable.Creator&lt;SavedState&gt;() {
            public SavedState createFromParcel(Parcel in) {
                return new SavedState(in);
            }

            public SavedState[] newArray(int size) {
                return new SavedState[size];
            }  
        };
    }  
}</pre>

Let me explain what I just did. 
First of all, since I override `onSaveInstanceState`, I have to call a supper method to let my super class save everything it wants to. In my case `Switch` will create a Parcelable, put state of the toggle and return it to me. Unfortunately, I cannot add some more states to this parcelable, so I need to create a wrapper around this super state and put my additional state to it. There is a handy class ([`View.BaseSavedState`](https://developer.android.com/reference/android/view/View.BaseSavedState.html)) in Android that does just that - saves super state and allows you to save your custom attributes by extending it.

During `onRestoreInstanceState()` we need to do the opposite - get super state from our special Parcelable and allow our super class to restore its state by calling`super.onRestoreInstanceState(ss.getSuperState())`. After that we can restore our own state.
> Since you override `onSaveInstanceState()` - always save super state - state of your super class.

### View IDs should be unique

Now I decided to reuse my awesome layout by separating it into custom view and including it within another layout couple of times: 
![](http://trickyandroid.com/content/images/2014/11/Screen-Shot-2014-11-02-at-12-25-33-PM.png)**But** when I change configuration - my states are all messed up! Let's see what we have in our `SparseArray`: ![](http://trickyandroid.com/content/images/2014/11/Screen-Shot-2014-11-02-at-12-26-19-PM.png)

Aha! Since states are stored based on view ID and `SparseArray` container is shared between entire view hierarchy - **view IDs should be unique!** Otherwise your state will be overwritten by another view with the same ID. In my case I have 2 views with id`@id/toggle`, so my states container holds only 1 instance of it - whichever came last during state store process. 
Now when it is time to restore state - both views will get the same state from the container.

_How do we solve it you ask?_

The quick answer to that - have seperate `SparseArray` containers for each set of children, so states do not overlap:
<pre>public class MyCustomLayout extends LinearLayout {

.........

    @Override
    public Parcelable onSaveInstanceState() {
        Parcelable superState = super.onSaveInstanceState();
        SavedState ss = new SavedState(superState);  
        ss.childrenStates = new SparseArray();  
        for (int i = 0; i &lt; getChildCount(); i++) {  
            getChildAt(i).saveHierarchyState(ss.childrenStates);
        }  
        return ss;
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        SavedState ss = (SavedState) state;
        super.onRestoreInstanceState(ss.getSuperState());  
        for (int i = 0; i &lt; getChildCount(); i++) {  
            getChildAt(i).restoreHierarchyState(ss.childrenStates);
        }  
    }

    @Override
    protected void dispatchSaveInstanceState(SparseArray&lt;Parcelable&gt; container) {
        dispatchFreezeSelfOnly(container);
    }

    @Override
    protected void dispatchRestoreInstanceState(SparseArray&lt;Parcelable&gt; container) {
        dispatchThawSelfOnly(container);
    }

    static class SavedState extends BaseSavedState {
        SparseArray childrenStates;

        SavedState(Parcelable superState) {  
            super(superState);
        }

        private SavedState(Parcel in, ClassLoader classLoader) {
            super(in);
            childrenStates = in.readSparseArray(classLoader);  
        }

        @Override
        public void writeToParcel(Parcel out, int flags) {
            super.writeToParcel(out, flags);
            out.writeSparseArray(childrenStates);  
        }

        public static final ClassLoaderCreator&lt;SavedState&gt; CREATOR
                = new ClassLoaderCreator&lt;SavedState&gt;() {
            @Override
            public SavedState createFromParcel(Parcel source, ClassLoader loader) {
                return new SavedState(source, loader);
            }

            @Override
            public SavedState createFromParcel(Parcel source) {
                return createFromParcel(null);
            }

            public SavedState[] newArray(int size) {
                return new SavedState[size];
            }  
        };
    }  
}</pre>

Let's go throught this mess:

*   In my custom layout I created a special `SaveState` class which holds super state**and** separate `SparseArray` for holding children states.
*   in `onSaveInstanceState()` I store super state **and** store my children states manually into separate `SparseArray`
*   in `onRestoreInstanceState()` I restore super state and restore my children states manually from `SparseArray` created during _save_ process
*   remember that if this is a `ViewGroup` - `dispatchSaveInstanceState()` goes through children and saves their states? Since we are doing this manually now - we need to disable this behavior. Luckily there is a convinient method`dispatchFreezeSelfOnly()` (should be called from `dispatchSaveInstanceState()`) which tells Android to save only ViewGroup's state and don't touch it's children.
*   the same thing should be done inside `dispatchRestoreInstanceState()` - we call`dispatchThawSelfOnly()`. Now we told Android to restore only our own state - and let us deal with our children manually.

And here is what our `SparseArray` looks like: 
![](http://trickyandroid.com/content/images/2014/11/Screen-Shot-2014-11-02-at-12-27-12-PM.png)

As we can see, each view group is now in a separate `SparseArray`, so they don't overlap and don't override each other.

State is saved! Profit!

As usual, source code for this article can be found [on GitHub](https://github.com/paveldudka/ViewStateSaveDemo)