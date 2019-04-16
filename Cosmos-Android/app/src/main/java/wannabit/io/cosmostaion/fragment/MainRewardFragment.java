package wannabit.io.cosmostaion.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.TabLayout;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Arrays;

import wannabit.io.cosmostaion.R;
import wannabit.io.cosmostaion.activities.MainActivity;
import wannabit.io.cosmostaion.activities.ValidatorActivity;
import wannabit.io.cosmostaion.base.BaseFragment;
import wannabit.io.cosmostaion.dialog.Dialog_My_ValidatorSorting;
import wannabit.io.cosmostaion.dialog.Dialog_ValidatorSorting;
import wannabit.io.cosmostaion.model.type.Validator;
import wannabit.io.cosmostaion.utils.WLog;

public class MainRewardFragment extends BaseFragment {

    public final static int SELECT_All_VALIDATOR_SORTING = 6002;
    public final static int SELECT_MY_VALIDATOR_SORTING = 6003;

    private ViewPager                   mValidatorPager;
    private TabLayout                   mValidatorTapLayer;
    private ValidatorPageAdapter        mPageAdapter;


    public static MainRewardFragment newInstance(Bundle bundle) {
        MainRewardFragment fragment = new MainRewardFragment();
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_main_reward, container, false);
        mValidatorTapLayer = rootView.findViewById(R.id.validator_tab);
        mValidatorPager = rootView.findViewById(R.id.validator_view_pager);

        mPageAdapter = new ValidatorPageAdapter(getChildFragmentManager());
        mValidatorPager.setAdapter(mPageAdapter);
        mValidatorTapLayer.setupWithViewPager(mValidatorPager);
        mValidatorTapLayer.setTabRippleColor(null);

        View tab0 = LayoutInflater.from(getContext()).inflate(R.layout.view_tab_myvalidator, null);
        TextView tabItemText0  = tab0.findViewById(R.id.tabItemText);
        tabItemText0.setText(getString(R.string.str_my_validators) + "(" + getMainActivity().mMyValidators.size() + ")");
        mValidatorTapLayer.getTabAt(0).setCustomView(tab0);

        View tab1 = LayoutInflater.from(getContext()).inflate(R.layout.view_tab_validator, null);
        TextView            tabItemText1  = tab1.findViewById(R.id.tabItemText);
        tabItemText1.setText(getString(R.string.str_all_validators)+ "(" + getMainActivity().mAllValidators.size() + ")");
        mValidatorTapLayer.getTabAt(1).setCustomView(tab1);
        mValidatorPager.setCurrentItem(0, false);

        mValidatorPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int i, float v, int i1) { }

            @Override
            public void onPageScrollStateChanged(int i) { }

            @Override
            public void onPageSelected(int i) {
                WLog.w("onPageSelected : " + i);
                mPageAdapter.mFragments.get(i).onRefreshTab();
            }
        });

        return rootView;
    }


    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.reward_menu, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.menu_sorting :
                if(mValidatorPager.getCurrentItem() == 1) {
                    onShowAllValidatorSort();
                } else {
                    onShowMyValidatorSort();
                }
                break;
            case R.id.menu_accounts :
                getMainActivity().onShowTopAccountsView();
                break;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onRefreshTab() {
        if(!isAdded()) return;
        mPageAdapter.getCurrentFragment().onRefreshTab();
        onUpdateTab();
    }

    private void onUpdateTab() {
        TabLayout.Tab tab0 = mValidatorTapLayer.getTabAt(0);
        View view0 = tab0.getCustomView();
        TextView tabItemText0 = view0.findViewById(R.id.tabItemText);
        tabItemText0.setText(getString(R.string.str_my_validators) + " (" + getMainActivity().mMyValidators.size() + ")");

        TabLayout.Tab tab1 = mValidatorTapLayer.getTabAt(1);
        View view1 = tab1.getCustomView();
        TextView tabItemText1 = view1.findViewById(R.id.tabItemText);
        tabItemText1.setText(getString(R.string.str_all_validators)+ " (" + getMainActivity().mAllValidators.size() + ")");
    }

    private void onShowAllValidatorSort() {
        Dialog_ValidatorSorting bottomSheetDialog = Dialog_ValidatorSorting.getInstance();
        bottomSheetDialog.setArguments(null);
        bottomSheetDialog.setTargetFragment(MainRewardFragment.this, SELECT_All_VALIDATOR_SORTING);
        bottomSheetDialog.show(getFragmentManager(), "dialog");
    }

    private void onShowMyValidatorSort() {
        Dialog_My_ValidatorSorting bottomSheetDialog = Dialog_My_ValidatorSorting.getInstance();
        bottomSheetDialog.setArguments(null);
        bottomSheetDialog.setTargetFragment(MainRewardFragment.this, SELECT_MY_VALIDATOR_SORTING);
        bottomSheetDialog.show(getFragmentManager(), "dialog");
    }



    public MainActivity getMainActivity() {
        return (MainActivity)getBaseActivity();
    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(requestCode == SELECT_All_VALIDATOR_SORTING && resultCode == Activity.RESULT_OK) {
            getBaseDao().setValSorting(data.getIntExtra("sorting", 1));
            mPageAdapter.mFragments.get(1).onRefreshTab();

        } else if(requestCode == SELECT_MY_VALIDATOR_SORTING && resultCode == Activity.RESULT_OK) {
            getBaseDao().setMyValSorting(data.getIntExtra("sorting", 1));
            mPageAdapter.mFragments.get(0).onRefreshTab();
        }
    }


    private class ValidatorPageAdapter extends FragmentPagerAdapter {

        private ArrayList<BaseFragment> mFragments = new ArrayList<>();
        private BaseFragment mCurrentFragment;

        public ValidatorPageAdapter(FragmentManager fm) {
            super(fm);
            mFragments.clear();
            mFragments.add(ValidatorMyFragment.newInstance(null));
            mFragments.add(ValidatorAllFragment.newInstance(null));
        }

        @Override
        public BaseFragment getItem(int position) {
            return mFragments.get(position);
        }

        @Override
        public int getCount() {
            return mFragments.size();
        }

        @Override
        public void setPrimaryItem(ViewGroup container, int position, Object object) {
            if (getCurrentFragment() != object) {
                mCurrentFragment = ((BaseFragment) object);
            }
            super.setPrimaryItem(container, position, object);
        }

        public BaseFragment getCurrentFragment() {
            return mCurrentFragment;
        }

        public ArrayList<BaseFragment> getFragments() {
            return mFragments;
        }
    }
}