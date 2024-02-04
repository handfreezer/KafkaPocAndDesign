package net.ulukai.kafka.connect.mirror;

import org.apache.kafka.connect.mirror.DefaultReplicationPolicy;

import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RegexReplicationPolicy extends DefaultReplicationPolicy {

    private static final Logger log = LoggerFactory.getLogger(RegexReplicationPolicy.class);

	private static final String REGEX_DETECT_CONFIG = "replication.policy.regex.detect";
	private static final String REGEX_REPLACE_CONFIG = "replication.policy.regex.replace";
	private Pattern patternDetect = Pattern.compile("(.*)");
	private String regexReplace = "$1";
	
    @Override
    public void configure(Map<String, ?> props) {
    	log.info("With {} , you can NOT change the separator.", this.getClass());
        if (props.containsKey(REGEX_REPLACE_CONFIG)) {
		    if (! props.containsKey(REGEX_DETECT_CONFIG)) {
	            log.error("Replace rule is defined but detect rule is not, so {} fallback to {}", this.getClass(), super.getClass());
		    } else {
	            String regexDetect = (String) props.get(REGEX_DETECT_CONFIG);
	            
	            try {
		            //this.patternDetect = Pattern.compile(Pattern.quote(regexDetect));
		            this.patternDetect = Pattern.compile(regexDetect);
		            log.info("Using regex detect rule: [{}]", regexDetect);
			        this.regexReplace = (String) props.get(REGEX_REPLACE_CONFIG);
		            log.info("Using regex replace rule: [{}]", this.regexReplace);
	            } catch (PatternSyntaxException e) {
	                log.error("Detect rule is NOT a valid regex [{}] : " + e.getMessage(), regexDetect);
	            } catch (IllegalStateException e) {
	                log.error("Detect rule compile failed with exception: " + e.getMessage());
	            }
            }
        }
    }

    private String transformTopic(String topic) {
    	String result = topic;
        try {
            Matcher matcher = this.patternDetect.matcher(topic);
            result = matcher.replaceAll(this.regexReplace);
        } catch (IllegalStateException e) {
            log.error("Replace rule failed with exception because of : " + e.getMessage());
        }
		return result;
    }
    
    public String formatRemoteTopic(String sourceClusterAlias, String topic) {
    	String remoteTopicCalulated = sourceClusterAlias + DefaultReplicationPolicy.SEPARATOR_DEFAULT + this.transformTopic(topic);
    	log.info("Format remote topic from [{}|{}] to [{}]", sourceClusterAlias, topic, remoteTopicCalulated);
        return remoteTopicCalulated;
    }
}
