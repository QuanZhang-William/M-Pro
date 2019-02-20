class WAWNode:
    def __init__(self, name, children, depth):
        self.name = name
        self.children = children
        self.depth = depth

    def add_children(self, dependency, i, max_depth):
        if i == max_depth:
            return

        for perm in dependency:
            if self.name == 'root':
                new_node = WAWNode(perm[i], set(), 0)
                self.children.add(new_node)
                new_node.add_children(dependency, i, max_depth)

            elif self.name == perm[i]:
                new_node = WAWNode(perm[i + 1], set(), i + 1)
                self.children.add(new_node)
                new_node.add_children(dependency, i + 1, max_depth)

class RAWNode:
    def __init__(self, name, children, depth, root_func):
        self.name = name
        self.children = children
        self.depth = depth
        self.root_func = root_func

    def add_children(self, dependency, i, max_depth, root_func):
        # for call depth 2
        if max_depth == 0:
            for perm in dependency:
                if self.name == 'root':
                    new_node = RAWNode(perm[i], set(), 0, root_func)
                    self.children.add(new_node)
                    new_node.add_children(dependency, i, max_depth, root_func)
                else:
                    new_node = RAWNode(root_func, set(), 0, root_func)
                    self.children.add(new_node)
                    return

        else:
            if i > max_depth:
                new_node = RAWNode(root_func, set(), i + 1, root_func)
                self.children.add(new_node)
                return

            for perm in dependency:
                if self.name == 'root':
                    new_node = RAWNode(perm[i], set(), 0, root_func)
                    self.children.add(new_node)
                    new_node.add_children(dependency, i, max_depth, root_func)

                elif self.name == perm[i]:
                    new_node = RAWNode(perm[i + 1], set(), i + 1, root_func)
                    self.children.add(new_node)
                    new_node.add_children(dependency, i + 1, max_depth, root_func)

