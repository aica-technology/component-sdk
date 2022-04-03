# JSON Schema for Component Descriptions

As components become more numerous and diverse, it is crucial to have a consistent means of describing individual
components and the interfaces they provide. A machine-readable component description should contain all necessary
information to procedurally generate documentation, frontend visualisations and backend services for any new component.

To facilitate this, a JSON schema defines the expected structure and contents of a component description.

The component description is intended to be fully comprehensive and cover the needs of both front and backend users.
For this reason, some low-level concepts from the backend framework are abstracted.

The sections in this document cover these concepts in more detail.
Components fundamentally use signals to send and receive data in the form of inputs and outputs. Components
have parameters with specific types and names that define their behaviour. Components also produce predicates,
which are special "true / false" signals to indicate specific component states that are used to trigger events.

The last section of this document describes some utility scripts which can be used to interact with the JSON schema,
and finally describes how to format and save the JSON component description file.

## Signals

The signals of a component should be described according to [signal.schema.json](./schema/signal.schema.json).

A "signal" is the generic term for data on a ROS2 topic. We use "input" to refer to subscriptions, and "output" to refer
to publications. This keeps the language concise and generic for a user who may not be familiar with ROS2 terminology. 

In the backend implementation, components must register their subscriptions and publications under named topics.
For lifecycle components, this happens in `on_configure`, and otherwise happens on construction.

In some cases, topic names can be "fixed" and immutable properties of the class. This is more often true for outputs
than inputs, but can occur in both cases.

However, for a component to be able to subscribe to a topic that another component is publishing at run-time,
the topic name must be configurable from the application either at the point of instantiation or configuration.
The way this is currently achieved is through string parameters, usually named as some derivative of "topic_name".
When configured, the component reads the topic name parameter and registers the corresponding subscriber or publisher.

Similarly, a component must also declare the signal type when registering the subscriptions and publications during
configuration. For dynamically typed signals, parameters are once again employed in the implementation.

In the frontend application graph, component parameters are displayed as editable fields on the component node.
But, because signals can be represented visually as edges (connections) between input and output nodes,
they should not also appear as editable "parameter" fields; this would bloat the apparent number of parameters of a
component with many signals and cause confusion for the user if there are multiple ways to configure signals.

For this reason, the implementation details of topic names as parameters are abstracted, and those parameters are
treated as "hidden" from the user. In the component description, the associated parameter is 
parameter values. In many cases, the literal topic name becomes irrelevant and could be automatically generated, as the
graph will visually show which components are connected and communicating on the corresponding signals. In practice,
the name of the topic between connected components should use the default topic name of the output as described
in the following section.

### Configurable signal topic names

The topic name of a signal is sometimes fixed and sometimes configurable. If the name is
configurable, then it must have an associated hidden parameter that sets the topic name before configuration. 

The following truth table shows the behaviour when connecting the output of one component with an input of another: 

| Output topic is configurable | Input topic is configurable | Result                                              |
|------------------------------|-----------------------------|-----------------------------------------------------|
| False                        | False                       | Compatible only if fixed topic names match          |
| True                         | False                       | Set output topic name from fixed input topic name   |
| False                        | True                        | Set input topic name from fixed output topic name   |
| True                         | True                        | Set input topic name from default output topic name |

The backend application interface is responsible for retrieving and setting the corresponding topic name parameter
from the application graph and component description.

### Configurable signal types

Similar to signal topic names, the signal type may also be configurable through hidden parameters, and has similar
behavior when resolving a new signal connection.

| Output type is configurable | Input type is configurable | Result                                  |
|-----------------------------|----------------------------|-----------------------------------------|
| False                       | False                      | Compatible only if fixed types match    |
| True                        | False                      | Set output type from fixed input type   |
| False                       | True                       | Set input type from fixed output type   |
| True                        | True                       | Set input type from default output type |

This has the extra caveat that the configurable signal type may only support a subset of all available types.
For example, a configurable component input might support CartesianPose or CartesianState signals, but nothing else.
In this case, the `supported_types` property in the signal description should be used along with parameter validation
by the component itself.

### Signal Collection

Just as the topic name or type of a single signal may be configurable at run-time, so too can the number of input
signals on a component be configurable.

A signal collection is a dynamic grouping of input signals with compatible types. For example, a WeightedSum component
supports a variable number of inputs that are defined at the application level. It may combine the outputs from
two components A and B in one application, but combine five different signals in another.

In the backend application, the dynamically configurable component inputs (subscriptions) of one collection
are generated from a single `string_array` parameter. The array of topic names in the parameter is used to
register the corresponding subscriptions.

Input collections are treated as a separate property from normal inputs because the structure of the default topic name
and topic parameter use arrays instead of simple strings. In addition, the frontend will also treat
simple input signals and input signal collection differently in terms of visualization and interaction.

When a new signal is added to a signal collection in the frontend, the backend appends the new signal topic name
to the associated hidden array parameter.  

## Parameters

Component classes declare a fixed set of parameters by name and type. The value of parameters are consumed by the
component when it is instantiated, or, in the case of lifecycle components, when it is configured.

Parameters can have a default value and in some cases are optional.

If a parameter is dynamically reconfigurable, it implies that the parameter can be changed after the component
is already configured to influence the run-time behaviour.
This requires the component to either poll the parameter value while running or implement a parameter change callback.

## Predicates

Predicates are crucial to drive the event logic of the dynamic state engine, but they are very simple to declare
and describe. Each predicate of a component indicates a particular run-time state or configuration that is either
"true" or "false". In the implementation, a predicate is a publisher with a boolean type. The component is responsible
for determining the value of a predicate and publishing it under a particular topic name.

In the component description, predicates have a display name and description. The `predicate_name` property is used
to inform the state engine of the hidden topic name to listen to for that predicate.

## Services

Services are endpoints provided by a component that can trigger certain behaviours. In the backend implementation,
they are created as ROS2 services with a specific `service_name` using one of two service message types. The first
type is simply an empty trigger service that has no payload, which is the default case. The second type is a trigger
service with a string payload, which can be used to pass parameters to the service call. The `has_payload` property
in the component description is used to specify the service type.

## Inheritance

Components can inherit signals, parameters, predicates and services from another component. This design pattern is
useful for generating a number of specific component variants that all derive from a common base class.

When component classes define their inheritance in C++ or Python implementations, the respective JSON component
descriptions can recursively include the full description of their parent components under the top-level `inherits`
property.

In practice, writing and storing nested JSON descriptions on file is not advisable since this leads to information
duplication and potential inconsistencies. Instead of a full component description, the `inherits` property can
alternatively be filled with a registration entry, listing just the `package` and `class` of the parent
component.

In both cases, the inheritance property should be used by a description parser or consumer to recursively expand all
properties (signals, parameters, predicates and services) into a flat and fully-comprehensive component description.

## Scripts

Two simple utility scripts are provided to view the schema and to validate JSON component descriptions.

To view the schema specifications in a nicer format, run the [`./serve-html.sh`](./serve-html.sh) script in this
directory. This will invoke a dockerized process in which a Python module `json-schema-for-humans` generate a static
HTML representation of the schema which is served on a localhost port for viewing in the browser.

To validate a component description, run the [`./validate.sh`](./validate.sh) script with a path to a JSON file.
The path can be relative or absolute. For example,
`./validate.sh examples/foo.json` or `./validate.sh /path/to/foo.json`.

Any invalidities in the component description, such as missing required fields, will be reported.

## Saving the component description

The component description JSON file should be saved in a `component_descriptions` directory of the package as a
`lower_snake_case` version of the registered class name.

For example, a component class in package `foo_package` registered as `foo_package::Foo` should be saved as follows:
```
foo_package/
    component_descriptions/
        foo_package_foo.json
    include/
        foo_package/
            Foo.h
    src/
        Foo.cpp
    ...
```

The component package `CMakeLists.txt` should include the following installation directive, which will install all
descriptions to `${WORKSPACE}/install/<package_name>/component_descriptions`.

```cmake
install(DIRECTORY ./component_descriptions
        DESTINATION .)
```