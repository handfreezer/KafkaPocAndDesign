package net.ulukai.kafka.connect.smt;

import org.apache.kafka.common.config.ConfigDef;
import org.apache.kafka.connect.connector.ConnectRecord;
import org.apache.kafka.connect.header.Headers;
import org.apache.kafka.connect.transforms.Transformation;
import org.apache.kafka.connect.transforms.util.SimpleConfig;

import java.util.Map;
import java.util.UUID;
import java.util.logging.Logger;

// this declaration in case of subclass instance needed
// public abstract class AddUuid<R extends ConnectRecord<R>> implements Transformation<R> {
public class AddUuid<R extends ConnectRecord<R>> implements Transformation<R> {

	private static Logger logger = Logger.getLogger(AddUuid.class.toString());

	public static final String OVERVIEW_DOC =
		"Insert a random UUID into a connect record ";

	private interface ConfigName {
		String UUID_FIELD_NAME = "uuid.field.name";
	}

	public static final ConfigDef CONFIG_DEF = new ConfigDef()
		.define(ConfigName.UUID_FIELD_NAME, ConfigDef.Type.STRING, "uuid", ConfigDef.Importance.HIGH,
				"Field name for UUID");

//	private static final String PURPOSE = "adding UUID to record";

	private String fieldName;

	@Override
	public void configure(Map<String, ?> props) {
		final SimpleConfig config = new SimpleConfig(CONFIG_DEF, props);
		this.fieldName = config.getString(ConfigName.UUID_FIELD_NAME);
		AddUuid.logger.info("Field name value is " + this.fieldName);
	}


	@Override
	public R apply(R record) {
		Headers newHeaders = record.headers().duplicate();
		String uuid = getRandomUuid();
		newHeaders.addString("ulukai_" + this.fieldName, uuid);
		AddUuid.logger.info("Adding uuid[" + uuid + "] to a message in topic " + record.topic() + " into field name ending with " +  this.fieldName);
		return record.newRecord(record.topic(),
				record.kafkaPartition(),
				record.keySchema(),
				record.key(),
				record.valueSchema(),
				record.value(),
				record.timestamp(),
				newHeaders);
	}

	@Override
	public ConfigDef config() {
		return CONFIG_DEF;
	}

	@Override
	public void close() {
	}

	private String getRandomUuid() {
		return UUID.randomUUID().toString();
	}

	//is to call a specific extension of SMT for A key, A value or something else instance, by specifying your class$specific
	public static class Key<R extends ConnectRecord<R>> extends AddUuid<R> {
	}

	public static class Value<R extends ConnectRecord<R>> extends AddUuid<R> {
	}
}
