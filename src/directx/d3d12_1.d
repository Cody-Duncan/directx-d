module directx.d3d12_1;

public import directx.d3d12;
public import directx.d3dcommon;
import std.bitmanip : bitfields;

// ----------------------------------------------------------------------------------------------------------
// State Object Prototype
// ----------------------------------------------------------------------------------------------------------

extern (Windows) interface ID3D12StateObjectPrototype : ID3D12Pageable
{
	HRESULT GetCachedBlob(ID3DBlob** ppBlob);
}

// ----------------------------------------------------------------------------------------------------------
// State SubObject Properties
// ----------------------------------------------------------------------------------------------------------

alias D3D12_STATE_SUBOBJECT_TYPE = uint;
enum : D3D12_STATE_SUBOBJECT_TYPE
{
	D3D12_STATE_SUBOBJECT_TYPE_FLAGS = 0,
	D3D12_STATE_SUBOBJECT_TYPE_ROOT_SIGNATURE = 1,
	D3D12_STATE_SUBOBJECT_TYPE_LOCAL_ROOT_SIGNATURE = 2,
	D3D12_STATE_SUBOBJECT_TYPE_NODE_MASK = 3,
	D3D12_STATE_SUBOBJECT_TYPE_CACHED_STATE_OBJECT = 4,
	D3D12_STATE_SUBOBJECT_TYPE_DXIL_LIBRARY = 5,
	D3D12_STATE_SUBOBJECT_TYPE_EXISTING_COLLECTION = 6,
	D3D12_STATE_SUBOBJECT_TYPE_SUBOBJECT_TO_EXPORTS_ASSOCIATION = 7,
	D3D12_STATE_SUBOBJECT_TYPE_DXIL_SUBOBJECT_TO_EXPORTS_ASSOCIATION = 8,
	D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_SHADER_CONFIG = 9,
	D3D12_STATE_SUBOBJECT_TYPE_RAYTRACING_PIPELINE_CONFIG = 10,
	D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP = 11,
	D3D12_STATE_SUBOBJECT_TYPE_MAX_VALID = (D3D12_STATE_SUBOBJECT_TYPE_HIT_GROUP + 1)
}

struct D3D12_STATE_SUBOBJECT
{
	D3D12_STATE_SUBOBJECT_TYPE Type;
	const void* pDesc;
}

alias D3D12_STATE_OBJECT_FLAGS = uint;
enum : D3D12_STATE_OBJECT_FLAGS
{
	D3D12_STATE_OBJECT_FLAG_NONE = 0
}

alias D3D12_EXPORT_FLAGS = uint;
enum : D3D12_EXPORT_FLAGS
{
	D3D12_EXPORT_FLAG_NONE = 0
}

struct D3D12_EXPORT_DESC
{
	LPCWSTR Name;
	LPCWSTR ExportToRename;
	D3D12_EXPORT_FLAGS Flags;
}

struct D3D12_DXIL_LIBRARY_DESC
{
	D3D12_SHADER_BYTECODE DXILLibrary;
	UINT NumExports;
	D3D12_EXPORT_DESC* pExports; // ArrayFormatNote: D3D12_EXPORT_DESC[NumExports] pExports
}

struct D3D12_EXISTING_COLLECTION_DESC
{
	ID3D12StateObjectPrototype* pExistingCollection;
	UINT NumExports;
	D3D12_EXPORT_DESC* pExports; // ArrayFormatNote: D3D12_EXPORT_DESC[NumExports] pExports
}

struct D3D12_SUBOBJECT_TO_EXPORTS_ASSOCIATION
{
	const D3D12_STATE_SUBOBJECT* pSubobjectToAssociate;
	UINT NumExports;
	LPCWSTR* pExports; // ArrayFormatNote: LPCWSTR[NumExports] pExports
}

struct D3D12_DXIL_SUBOBJECT_TO_EXPORTS_ASSOCIATION
{
	LPCWSTR SubobjectToAssociate;
	UINT NumExports;
	LPCWSTR* pExports; // ArrayFormatNote: LPCWSTR[NumExports] pExports
}

// ----------------------------------------------------------------------------------------------------------
// Raytracing, Geometry, Acceleration Structures
// ----------------------------------------------------------------------------------------------------------

struct D3D12_HIT_GROUP_DESC
{
	LPCWSTR HitGroupExport;
	LPCWSTR AnyHitShaderImport; //optional
	LPCWSTR ClosestHitShaderImport; //optional
	LPCWSTR IntersectionShaderImport; //optional
}

struct D3D12_RAYTRACING_SHADER_CONFIG
{
	UINT MaxPayloadSizeInBytes;
	UINT MaxAttributeSizeInBytes;
}

struct D3D12_RAYTRACING_PIPELINE_CONFIG
{
	UINT MaxTraceRecursionDepth;
}

alias D3D12_STATE_OBJECT_TYPE = uint;
enum : D3D12_STATE_OBJECT_TYPE
{
	D3D12_STATE_OBJECT_TYPE_COLLECTION = 0,
	D3D12_STATE_OBJECT_TYPE_RAYTRACING_PIPELINE = 3
}

struct D3D12_STATE_OBJECT_DESC
{
	D3D12_STATE_OBJECT_TYPE Type;
	UINT NumSubobjects;
	const D3D12_STATE_SUBOBJECT* pSubobjects; // ArrayFormatNote: const D3D12_STATE_SUBOBJECT[NumSubobjects] pSubobjects
}

alias D3D12_RAYTRACING_GEOMETRY_FLAGS = uint;
enum : D3D12_RAYTRACING_GEOMETRY_FLAGS
{
	D3D12_RAYTRACING_GEOMETRY_FLAG_NONE = 0,
	D3D12_RAYTRACING_GEOMETRY_FLAG_OPAQUE = 0x1,
	D3D12_RAYTRACING_GEOMETRY_FLAG_NO_DUPLICATE_ANYHIT_INVOCATION = 0x2
}

alias D3D12_RAYTRACING_GEOMETRY_TYPE = uint;
enum : D3D12_RAYTRACING_GEOMETRY_TYPE
{
	D3D12_RAYTRACING_GEOMETRY_TYPE_TRIANGLES = 0,
	D3D12_RAYTRACING_GEOMETRY_TYPE_PROCEDURAL_PRIMITIVE_AABBS = (D3D12_RAYTRACING_GEOMETRY_TYPE_TRIANGLES + 1)
}

alias D3D12_RAYTRACING_INSTANCE_FLAGS = uint;
enum : D3D12_RAYTRACING_INSTANCE_FLAGS
{
	D3D12_RAYTRACING_INSTANCE_FLAG_NONE = 0,
	D3D12_RAYTRACING_INSTANCE_FLAG_TRIANGLE_CULL_DISABLE = 0x1,
	D3D12_RAYTRACING_INSTANCE_FLAG_TRIANGLE_FRONT_COUNTERCLOCKWISE = 0x2,
	D3D12_RAYTRACING_INSTANCE_FLAG_FORCE_OPAQUE = 0x4,
	D3D12_RAYTRACING_INSTANCE_FLAG_FORCE_NON_OPAQUE = 0x8
}

struct D3D12_GPU_VIRTUAL_ADDRESS_AND_STRIDE
{
	D3D12_GPU_VIRTUAL_ADDRESS StartAddress;
	UINT64 StrideInBytes;
}

struct D3D12_GPU_VIRTUAL_ADDRESS_RANGE
{
	D3D12_GPU_VIRTUAL_ADDRESS StartAddress;
	UINT64 SizeInBytes;
}

struct D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE
{
	D3D12_GPU_VIRTUAL_ADDRESS StartAddress;
	UINT64 SizeInBytes;
	UINT64 StrideInBytes;
}

struct D3D12_RAYTRACING_GEOMETRY_TRIANGLES_DESC
{
	D3D12_GPU_VIRTUAL_ADDRESS Transform;
	DXGI_FORMAT IndexFormat;
	DXGI_FORMAT VertexFormat;
	UINT IndexCount;
	UINT VertexCount;
	D3D12_GPU_VIRTUAL_ADDRESS IndexBuffer;
	D3D12_GPU_VIRTUAL_ADDRESS_AND_STRIDE VertexBuffer;
}

struct D3D12_RAYTRACING_AABB
{
	FLOAT MinX;
	FLOAT MinY;
	FLOAT MinZ;
	FLOAT MaxX;
	FLOAT MaxY;
	FLOAT MaxZ;
}

struct D3D12_RAYTRACING_GEOMETRY_AABBS_DESC
{
	UINT64 AABBCount;
	D3D12_GPU_VIRTUAL_ADDRESS_AND_STRIDE AABBs;
}

struct D3D12_RAYTRACING_GEOMETRY_DESC
{
	D3D12_RAYTRACING_GEOMETRY_TYPE Type;
	D3D12_RAYTRACING_GEOMETRY_FLAGS Flags;
	union
	{
		D3D12_RAYTRACING_GEOMETRY_TRIANGLES_DESC Triangles;
		D3D12_RAYTRACING_GEOMETRY_AABBS_DESC AABBs;
	}
}

alias D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS = uint;
enum : D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_NONE = 0,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_ALLOW_UPDATE = 0x1,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_ALLOW_COMPACTION = 0x2,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_PREFER_FAST_TRACE = 0x4,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_PREFER_FAST_BUILD = 0x8,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_MINIMIZE_MEMORY = 0x10,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAG_PERFORM_UPDATE = 0x20
}

alias D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE = uint;
enum : D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE_CLONE = 0,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE_COMPACT = 0x1,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE_VISUALIZATION_DECODE_FOR_TOOLS = 0x2,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE_SERIALIZE = 0x3,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE_DESERIALIZE = 0x4
}

alias D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE = uint;
enum : D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL = 0,
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL = 0x1
}

struct D3D12_RAYTRACING_INSTANCE_DESC
{
	FLOAT[12] Transform;

	mixin(bitfields!(
		UINT, "InstanceID", 24, 
		UINT, "InstanceMask", 8, 
		UINT, "InstanceContributionToHitGroupIndex", 24, 
		UINT, "Flags", 8
	));

	D3D12_GPU_VIRTUAL_ADDRESS AccelerationStructure;
}

struct D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO
{
	UINT64 ResultDataMaxSizeInBytes;
	UINT64 ScratchDataSizeInBytes;
	UINT64 UpdateScratchDataSizeInBytes;
}

alias D3D12_ELEMENTS_LAYOUT = uint;
enum : D3D12_ELEMENTS_LAYOUT
{
	D3D12_ELEMENTS_LAYOUT_ARRAY = 0,
	D3D12_ELEMENTS_LAYOUT_ARRAY_OF_POINTERS = 0x1
}

struct D3D12_GET_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO_DESC
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE Type;
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS Flags;
	UINT NumDescs;
	D3D12_ELEMENTS_LAYOUT DescsLayout;
	union
	{
		const D3D12_RAYTRACING_GEOMETRY_DESC* pGeometryDescs;
		const D3D12_RAYTRACING_GEOMETRY_DESC** ppGeometryDescs;
	}
}

alias D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE = uint;
enum : D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_COMPACTED_SIZE = 0,

	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TOOLS_VISUALIZATION = (
			D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_COMPACTED_SIZE + 1),

	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_SERIALIZATION = (
			D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TOOLS_VISUALIZATION + 1)
}

struct D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_COMPACTED_SIZE_DESC
{
	UINT64 CompactedSizeInBytes;
}

struct D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TOOLS_VISUALIZATION_DESC
{
	UINT64 DecodedSizeInBytes;
}

struct D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_TOOLS_VISUALIZATION_HEADER
{
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE Type;
	UINT NumDescs;
}

// Regarding D3D12_BUILD_RAY_TRACING_ACCELERATION_STRUCTURE_TOOLS_VISUALIZATION_HEADER above,
// depending on Type field, NumDescs above is followed by either:
//	   D3D12_RAY_TRACING_INSTANCE_DESC InstanceDescs[NumDescs]
//	or D3D12_RAY_TRACING_GEOMETRY_DESC GeometryDescs[NumDescs].
// There is 4 bytes of padding between GeometryDesc structs in the array so alignment is natural when viewed by CPU.

struct D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_SERIALIZATION_DESC
{
	UINT64 SerializedSizeInBytes;
	UINT64 NumBottomLevelAccelerationStructurePointers;
}

struct D3D12_SERIALIZED_ACCELERATION_STRUCTURE_HEADER
{
	UINT64 SerializedSizeInBytesIncludingHeader;
	UINT64 DeserializedSizeInBytes;
	UINT64 NumBottomLevelAccelerationStructurePointersAfterHeader;
}

struct D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC
{
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE DestAccelerationStructureData;
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_TYPE Type;
	UINT NumDescs;
	D3D12_ELEMENTS_LAYOUT DescsLayout;
	union
	{
		D3D12_GPU_VIRTUAL_ADDRESS InstanceDescs;
		const D3D12_RAYTRACING_GEOMETRY_DESC* pGeometryDescs;
		const D3D12_RAYTRACING_GEOMETRY_DESC** ppGeometryDescs;
	}
	D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS Flags;
	D3D12_GPU_VIRTUAL_ADDRESS SourceAccelerationStructureData; // optional
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE ScratchAccelerationStructureData;
}

struct D3D12_DISPATCH_RAYS_DESC
{
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE RayGenerationShaderRecord;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE MissShaderTable;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE HitGroupTable;
	D3D12_GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE CallableShaderTable;
	UINT Width;
	UINT Height;
}

enum D3D12_RAYTRACING_ACCELERATION_STRUCTURE_BYTE_ALIGNMENT = 256;
enum D3D12_RAYTRACING_INSTANCE_DESCS_BYTE_ALIGNMENT = 16;
enum D3D12_RAYTRACING_MAX_ATTRIBUTE_SIZE_IN_BYTES = 32;
enum D3D12_RAYTRACING_SHADER_RECORD_BYTE_ALIGNMENT = 16;
enum D3D12_RAYTRACING_MAX_DECLARABLE_TRACE_RECURSION_DEPTH = 31;
enum D3D12_RAYTRACING_AABB_BYTE_ALIGNMENT = 4;

extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0007_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0007_v0_0_s_ifspec;

// ----------------------------------------------------------------------------------------------------------
// Device Raytracing Prototype
// ----------------------------------------------------------------------------------------------------------

mixin(uuid!(ID3D12DeviceRaytracingPrototype, "f52ef3ca-f710-4ee4-b873-a7f504e43995"));
extern (Windows) interface ID3D12DeviceRaytracingPrototype : IUnknown
{
	HRESULT CreateStateObject(
		const D3D12_STATE_OBJECT_DESC* pDesc, REFIID riid,
		void** ppStateObject); //out

	UINT GetShaderIdentifierSize();

	void GetRaytracingAccelerationStructurePrebuildInfo(
		D3D12_GET_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO_DESC* pDesc, // in
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO* pInfo); // out
}

// ----------------------------------------------------------------------------------------------------------
// Command List Raytracing Prototype
// ----------------------------------------------------------------------------------------------------------

mixin(uuid!(ID3D12CommandListRaytracingPrototype, "3c69787a-28fa-4701-970a-37a1ed1f9cab"));
extern (Windows) interface ID3D12CommandListRaytracingPrototype : IUnknown
{
	void BuildRaytracingAccelerationStructure(
		const D3D12_BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC* pDesc);

	void EmitRaytracingAccelerationStructurePostBuildInfo(
		D3D12_GPU_VIRTUAL_ADDRESS_RANGE DestBuffer,
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE InfoType,
		UINT NumSourceAccelerationStructures,
		const D3D12_GPU_VIRTUAL_ADDRESS* pSourceAccelerationStructureData); // ArrayFormatNote: const D3D12_GPU_VIRTUAL_ADDRESS[NumSourceAccelerationStructures] pSourceAccelerationStructureData

	void CopyRaytracingAccelerationStructure(
		D3D12_GPU_VIRTUAL_ADDRESS_RANGE DestAccelerationStructureData,
		D3D12_GPU_VIRTUAL_ADDRESS SourceAccelerationStructureData,
		D3D12_RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE Mode);

	void DispatchRays(
		ID3D12StateObjectPrototype* pRaytracingPipelineState,
		const D3D12_DISPATCH_RAYS_DESC* pDesc);
}

alias D3D12_METACOMMAND_PARAMETER_TYPE = uint;
enum : D3D12_METACOMMAND_PARAMETER_TYPE
{
	D3D12_METACOMMAND_PARAMETER_FLOAT = 0,
	D3D12_METACOMMAND_PARAMETER_UINT64 = 1,
	D3D12_METACOMMAND_PARAMETER_BUFFER_UAV = 2,
	D3D12_METACOMMAND_PARAMETER_BINDPOINT_IN_SHADER = 3
}

alias D3D12_METACOMMAND_PARAMETER_ATTRIBUTES = uint;
enum : D3D12_METACOMMAND_PARAMETER_ATTRIBUTES
{
	D3D12_METACOMMAND_PARAMETER_INPUT = 0x1,
	D3D12_METACOMMAND_PARAMETER_OUTPUT = 0x2
}

alias D3D12_METACOMMAND_PARAMETER_MUTABILITY = uint;
enum : D3D12_METACOMMAND_PARAMETER_MUTABILITY
{
	D3D12_METACOMMAND_PARAMETER_MUTABILITY_PER_EXECUTE = 0,
	D3D12_METACOMMAND_PARAMETER_MUTABILITY_CREATION_ONLY = 1,
	D3D12_METACOMMAND_PARAMETER_MUTABILITY_INITIALIZATION_ONLY = 2
}

struct D3D12_METACOMMAND_PARAMETER_DESC
{
	char[128] Name;
	D3D12_METACOMMAND_PARAMETER_TYPE Type;
	D3D12_METACOMMAND_PARAMETER_ATTRIBUTES Attributes;
	D3D12_METACOMMAND_PARAMETER_MUTABILITY Mutability;
}

alias D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE = uint;
enum : D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE
{
	D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE_CBV = 0,
	D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE_SRV = (D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE_CBV + 1),
	D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE_UAV = (D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE_SRV + 1)
}

struct D3D12_BINDPOINT_IN_SHADER
{
	D3D12_METACOMMAND_BINDPOINT_PARAMETER_TYPE Type;
	UINT Register;
	UINT Space;
}

struct D3D12_METACOMMAND_PARAMETER_DATA
{
	UINT ParameterIndex;
	union
	{
		FLOAT FloatValue;
		UINT64 UnsignedInt64Value;
		D3D12_GPU_VIRTUAL_ADDRESS BufferLocation;
		D3D12_BINDPOINT_IN_SHADER BindingInfo;
	}
}

struct D3D12_METACOMMAND_DESCRIPTION
{
	GUID Id;
	char[128] Name;
	UINT SignatureCount;
}

extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0009_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0009_v0_0_s_ifspec;

// ----------------------------------------------------------------------------------------------------------
// Device Meta Command
// ----------------------------------------------------------------------------------------------------------

mixin(uuid!(ID3D12DeviceMetaCommand, "547e33c7-ff86-4cd9-bea3-5d4a28375396"));
extern (Windows) interface ID3D12DeviceMetaCommand : IUnknown
{
	HRESULT EnumerateMetaCommands(
		UINT* pNumMetaCommands, // inout
		D3D12_METACOMMAND_DESCRIPTION* pDescs); // optional, writes out num of pNumMetaCommands

	HRESULT EnumerateMetaCommandSignature(
		REFGUID CommandId, UINT SignatureId,
		UINT* pParameterCount, // inout
		D3D12_METACOMMAND_PARAMETER_DESC* pParameterDescs); // optional, writes out num of pParameterCount

	HRESULT CreateMetaCommand(
		REFGUID CommandId, UINT SignatureId, ID3D12RootSignature* pRootSignature, // optional
		UINT NumParameters,
		const D3D12_METACOMMAND_PARAMETER_DATA* pParameters, // ArrayFormatNote: const D3D12_METACOMMAND_PARAMETER_DATA[NumParameters] pParameters
		REFIID riid, void** ppMetaCommand);
}

// ----------------------------------------------------------------------------------------------------------
// Meta Command
// ----------------------------------------------------------------------------------------------------------

mixin(uuid!(ID3D12MetaCommand, "8AFDA767-8003-494F-9E9A-4AA8864F3524"));
extern (Windows) interface ID3D12MetaCommand : ID3D12Pageable
{
	void GetRequiredParameterResourceSize(
		UINT32 ParameterIndex, UINT64* SizeInBytes);
}

// ----------------------------------------------------------------------------------------------------------
// Command List Meta Command
// ----------------------------------------------------------------------------------------------------------

mixin(uuid!(ID3D12CommandListMetaCommand, "5A5F59F3-7124-4766-8E9E-CB637764FB0B"));
extern (Windows) interface ID3D12CommandListMetaCommand : IUnknown
{
	void InitializeMetaCommand(
		ID3D12MetaCommand* pMetaCommand,
		UINT NumParameters, const D3D12_METACOMMAND_PARAMETER_DATA* pParameters);

	void ExecuteMetaCommand(
		ID3D12MetaCommand* pMetaCommand, UINT NumParameters,
		const D3D12_METACOMMAND_PARAMETER_DATA* pParameters); // ArrayFormatNote: const D3D12_METACOMMAND_PARAMETER_DATA[NumParameters] pParameters
}

extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0012_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL_itf_d3d12_1_0000_0012_v0_0_s_ifspec;
