#include "ControlFlowGraph.hpp"

Graph::Graph(BasicBlock baseBlock) : lastAddedBlockID(baseBlock.blockID) {
	map.push_back(baseBlock);

	vector<int> block;
	block.push_back(lastAddedBlockID);
	graph.push_back(block);
}


void Graph::addEdge(int srcBlockID, BasicBlock destBlock)
{
	createNewNode(destBlock);
	if (srcBlockID != destBlock.blockID) {
		graph.at(srcBlockID).push_back(destBlock.blockID);
	}
}

BasicBlock Graph::getBasicBlock(int blockId)
{
	return map.at(blockId);
}

void Graph::dumpGraph()
{
	printf("block id: connected blocks sperated by white space\n");
	for (int row = 1; row < graph.size(); row++) {
		int bid = graph[row][0];
		printf("block %3d: ", bid);
		for (int col = 1; col < graph[row].size(); col++) {
			printf("%3d ", graph[row][col]);
		}
		printf("\n");
	}

	printf("\nNow printing blocks\n");
	for (int row = 1; row < map.size(); row++) {
		printf("\nThis is block %3d\n", map[row].blockID);
		cout << map[row].dumpBasicBlock();
	}

}

void Graph::createNewNode(BasicBlock block)
{
	int blockId = block.blockID;

	//push the new block to the map vector. map is a list of BasicBlocks
	map.push_back(block);

	//Update the lastAddedBlockId
	lastAddedBlockID = blockId;

	//Create a new block and push the blockId to it
	vector<int> newBlock;
	newBlock.push_back(blockId);

	//Finally push the new block with its blockID to the graph
	graph.push_back(newBlock);
}





