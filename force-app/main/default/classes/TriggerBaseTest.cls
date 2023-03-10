/*
   Copyright 2020 Google LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

@SuppressWarnings('PMD.ApexDoc, PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(isParallel=true)
private class TriggerBaseTest {
	private static final String ACCOUNT = 'Account';
	private static final String BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY = 'The bypasses should be configured correctly';
	private static final String NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT = 'The number of time seen should be populated properly';
	private static final String RUN_SUCCESS = 'Run should be successful ';

	private static final Account MY_ACCOUNT = new Account(
		Id = TriggerTestUtility.getFakeId(Schema.Account.SObjectType),
		Name = 'My Account'
	);
	private static BaseTest base = new BaseTest();
	private static Exception myException;

	static {
		base.triggerNew = new List<SObject>{ MY_ACCOUNT };
		base.triggerOld = new List<SObject>{ MY_ACCOUNT };
	}

	@IsTest
	private static void sObjectNameShouldBePopulatedFromTriggerNew() {
		base.triggerOld = null;

		String sObjectName = base.sObjectName;

		System.Assert.areEqual(
			sObjectName,
			ACCOUNT,
			'Name should be populated from elements of triggerOld'
		);
	}

	@IsTest
	private static void sObjectNameShouldBePopulatedFromTriggerOld() {
		base.triggerNew = null;

		String sObjectName = base.sObjectName;

		System.Assert.areEqual(
			sObjectName,
			ACCOUNT,
			'Name should be populated from elements of triggerNew'
		);
	}

	@IsTest
	private static void oldAndNewShouldComeFromTrigger() {
		base.triggerNew = null;
		base.triggerOld = null;

		System.Assert.areEqual(
			null,
			base.triggerNew,
			'triggerNew should match Trigger.new'
		);
		System.Assert.areEqual(
			null,
			base.triggerOld,
			'triggerOld should match Trigger.old'
		);
	}

	@IsTest
	private static void beforeInsertShouldSucceed() {
		MY_ACCOUNT.Id = null;
		base.context = System.TriggerOperation.BEFORE_INSERT;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterInsertShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_INSERT;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void beforeUpdateShouldSucceed() {
		base.context = System.TriggerOperation.BEFORE_UPDATE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterUpdateShouldSucceed() {
		base.context = System.TriggerOperation.After_UPDATE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void beforeDeleteShouldSucceed() {
		base.context = System.TriggerOperation.BEFORE_DELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterDeleteShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_DELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void afterUndeleteShouldSucceed() {
		base.context = System.TriggerOperation.AFTER_UNDELETE;

		base.run();

		System.Assert.isTrue(base.executed, RUN_SUCCESS);
	}

	@IsTest
	private static void idToNumberOfTimesSeenBeforeUpdate() {
		base.context = System.TriggerOperation.BEFORE_UPDATE;

		base.run();
		base.run();

		System.Assert.areEqual(
			2,
			TriggerBase.idToNumberOfTimesSeenBeforeUpdate.get(MY_ACCOUNT.Id),
			NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT
		);
	}

	@IsTest
	private static void idToNumberOfTimesSeenAfterUpdate() {
		base.context = System.TriggerOperation.AFTER_UPDATE;

		base.run();
		base.run();

		System.Assert.areEqual(
			2,
			TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(MY_ACCOUNT.Id),
			NUMBER_OF_TIMES_SEEN_SHOULD_BE_CORRECT
		);
	}

	@IsTest
	private static void runShouldFailWhenCalledOutsideTrigger() {
		try {
			base.run();
		} catch (Exception e) {
			myException = e;
		}

		System.Assert.areNotEqual(
			null,
			myException,
			'An exception should be thrown'
		);
		System.Assert.isTrue(
			myException.getMessage()
				.contains(TriggerBase.HANDLER_OUTSIDE_TRIGGER_MESSAGE),
			'The exception should be the one we are looking for'
		);
	}

	@IsTest
	private static void runShouldDoNothingWhenBypassed() {
		MY_ACCOUNT.Id = null;
		TriggerBase.bypass(ACCOUNT);
		base.context = System.TriggerOperation.BEFORE_INSERT;

		base.run();

		System.Assert.isFalse(base.executed, 'The base should not have executed');
	}

	@IsTest
	private static void bypassShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		System.Assert.isTrue(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void clearBypassShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		TriggerBase.clearBypass(ACCOUNT);

		System.Assert.isFalse(
			TriggerBase.bypassedObjects.contains(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void isBypassedShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		System.Assert.isTrue(
			TriggerBase.isBypassed(ACCOUNT),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	@IsTest
	private static void clearAllBypassesShouldSucceed() {
		TriggerBase.bypass(ACCOUNT);

		TriggerBase.clearAllBypasses();

		System.Assert.areEqual(
			0,
			TriggerBase.bypassedObjects.size(),
			BYPASSES_SHOULD_BE_CONFIGURED_CORRECTLY
		);
	}

	class BaseTest extends TriggerBase implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert, TriggerAction.BeforeUpdate, TriggerAction.AfterUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterDelete, TriggerAction.AfterUndelete {
		public Boolean executed = false;
		public void beforeInsert(List<SObject> newList) {
			this.executed = true;
		}
		public void afterInsert(List<SObject> newList) {
			this.executed = true;
		}
		public void beforeUpdate(List<SObject> newList, List<SObject> oldList) {
			this.executed = true;
		}
		public void afterUpdate(List<SObject> newList, List<SObject> oldList) {
			this.executed = true;
		}
		public void beforeDelete(List<SObject> oldList) {
			this.executed = true;
		}
		public void afterDelete(List<SObject> newList) {
			this.executed = true;
		}
		public void afterUndelete(List<SObject> newList) {
			this.executed = true;
		}
	}
}
