<#-- @formatter:off -->
<#macro procedureCode object dependencies={}>
    <#compress>
    <#assign deps = [] />
    <#list object.getDependencies(generator.getWorkspace()) as dependency>
        <#assign deps += [dependency.getName()] />
    </#list>
    <#if deps?size == 0>
        ${object.getName()}Procedure.execute(Collections.EMPTY_MAP);
    <#else>
        ${object.getName()}Procedure.execute(com.google.common.collect.ImmutableMap.<String, Object>builder()
        <#list dependencies as name, value>
            <#if deps?seq_contains(name)>.put("${name}", ${value})</#if>
        </#list>
        .build());
    </#if>
    </#compress>
</#macro>

<#macro procedureCodeWithOptResult object type defaultResult dependencies={}>
    <#if hasReturnValueOf(object, type)>
        return <@procedureCode object dependencies/>
    <#else>
        <@procedureCode object dependencies/>
        return ${defaultResult};
    </#if>
</#macro>

<#macro procedureToRetvalCode name dependencies customVals={}>
    <#assign depsBuilder = []>

    <#list dependencies as dependency>
        <#if !customVals[dependency.getName()]?? >
            <#assign depsBuilder += ["\"" + dependency.getName() + "\", " + dependency.getName()]>
        </#if>
    </#list>

    <#list customVals as key, value>
        <#assign depsBuilder += ["\"" + key + "\", " + value]>
    </#list>

    ${(name)}Procedure.execute(com.google.common.collect.ImmutableMap.<String, Object>builder()<#list depsBuilder as dep>.put(${dep})</#list>.build())
</#macro>

<#macro procedureToCode name dependencies customVals={}>
    <@procedureToRetvalCode name dependencies customVals/>;
</#macro>

<#macro procedureOBJToCode object="">
    <#if hasProcedure(object)>
        <@procedureToCode name=object.getName() dependencies=object.getDependencies(generator.getWorkspace()) />
    </#if>
</#macro>

<#macro procedureOBJToConditionCode object="" defaultValue=true invertCondition=false>
    <#if hasProcedure(object)>
        <#if invertCondition>!</#if><@procedureToRetvalCode name=object.getName() dependencies=object.getDependencies(generator.getWorkspace()) />
    <#else>
        ${defaultValue?c}
    </#if>
</#macro>

<#macro procedureOBJToNumberCode object="">
    <#if hasProcedure(object)>
        <@procedureToRetvalCode name=object.getName() dependencies=object.getDependencies(generator.getWorkspace()) />
    <#else>
        0
    </#if>
</#macro>

<#macro procedureOBJToItemstackCode object="">
    <#if hasProcedure(object)>
        /*@ItemStack*/ <@procedureToRetvalCode name=object.getName() dependencies=object.getDependencies(generator.getWorkspace()) />
    <#else>
        /*@ItemStack*/ ItemStack.EMPTY
    </#if>
</#macro>

<#macro procedureOBJToInteractionResultCode object="">
    <#if hasProcedure(object)>
        <@procedureToRetvalCode name=object.getName() dependencies=object.getDependencies(generator.getWorkspace()) />
    <#else>
        InteractionResult.PASS
    </#if>
</#macro>

<#function hasProcedure object="">
    <#return object?? && object?has_content && object.getName()?has_content && object.getName() != "null">
</#function>

<#function hasReturnValueOf object="" type="">
    <#return hasProcedure(object) && (object.getReturnValueType(generator.getWorkspace()) == type)>
</#function>

<#-- @formatter:on -->